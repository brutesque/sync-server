#!/usr/bin/env bash

# OpenSSH-server
# https://linux-audit.com/audit-and-harden-your-ssh-configuration/

AUTH_KEYS=$(cat ~/.ssh/authorized_keys)
if [[ -z "$AUTH_KEYS" ]]; then
    echo
    echo "SSH keys not installed for this account. Aborting..."
    exit 1
fi

sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old

# Public key authentication
# Instead of using a normal password-based login, a better way is using public key authentication. Keys are considered
# much safer and less prone to brute-force attacks. Disable PasswordAuthentication to force users using keys.
PARAM_VALID=$(sshd -T |grep pubkeyauthentication |grep yes)
if [[ -z "$PARAM_VALID" ]]; then
    SED_PARAM="s/PubkeyAuthentication .*/PubkeyAuthentication yes/"
    sudo sh -c "sed \"$SED_PARAM\" /etc/ssh/sshd_config > /etc/ssh/sshd_config.new && mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config"
fi

PARAM_VALID=$(sshd -T |grep passwordauthentication |grep no)
if [[ -z "$PARAM_VALID" ]]; then
    SED_PARAM="s/#PasswordAuthentication .*/PasswordAuthentication no/"
    sudo sh -c "sed \"$SED_PARAM\" /etc/ssh/sshd_config > /etc/ssh/sshd_config.new && mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config"
fi

# Disable empty passwords
# Accounts should be protected and users should be accountable. For this reason, the usage of empty passwords should not
# be allowed. This can be disabled with the PermitEmptyPasswords option, which is the default.
PARAM_VALID=$(sshd -T |grep permitemptypasswords |grep no)
if [[ -z "$PARAM_VALID" ]]; then
    SED_PARAM="s/#PermitEmptyPasswords .*/PermitEmptyPasswords no/"
    sudo sh -c "sed \"$SED_PARAM\" /etc/ssh/sshd_config > /etc/ssh/sshd_config.new && mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config"
fi

# Disable root login
# It is best practice not to log in as the root user. Use a normal user account to initiate your connection instead,
# together with sudo. Direct root logins may result in bad accountability of the actions performed by this user account.
PARAM_VALID=$(sshd -T |grep permitrootlogin |grep no)
if [[ -z "$PARAM_VALID" ]]; then
    SED_PARAM="s/#PermitRootLogin .*/PermitRootLogin no/"
    sudo sh -c "sed \"$SED_PARAM\" /etc/ssh/sshd_config > /etc/ssh/sshd_config.new && mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config"
fi

# Use of X11Forwarding
# The display server on the client might have a higher exposure to be attacked with X11 traffic forwarded. If forwarding
# of X11 traffic is not needed, disable it:
PARAM_VALID=$(sshd -T |grep x11forwarding |grep no)
if [[ -z "$PARAM_VALID" ]]; then
    SED_PARAM="s/X11Forwarding .*/X11Forwarding no/"
    sudo sh -c "sed \"$SED_PARAM\" /etc/ssh/sshd_config > /etc/ssh/sshd_config.new && mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config"
fi

# Maximum authentication attempts
# To protect against brute-force attacks on the password of a user, limit the number of attempts. This can be done with
# the MaxAuthTries setting.
PARAM_VALID=$(sshd -T |grep maxauthtries |grep 6)
if [[ -z "$PARAM_VALID" ]]; then
    SED_PARAM="s/#MaxAuthTries .*/MaxAuthTries 6/"
    sudo sh -c "sed \"$SED_PARAM\" /etc/ssh/sshd_config > /etc/ssh/sshd_config.new && mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config"
fi

PARAM_VALID=$(sshd -T |grep allowusers |grep "$USER")
if [[ -z "$PARAM_VALID" ]]; then
    sudo sh -c "echo AllowUsers $USER >> /etc/ssh/sshd_config"
fi

# Restart OpenSSH-server
sudo systemctl restart ssh


# Firewall
# https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-18-04

sudo apt-get update && sudo apt-get install --yes ufw

# set the defaults to deny incoming and allow outgoing connections
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allowing SSH connections
sudo ufw allow OpenSSH
sudo ufw limit OpenSSH

# Allowing http and https connections
sudo ufw allow http
sudo ufw allow https

# Allow port 55555 for resilio sync
sudo ufw allow 55555

# Enabling UFW
sudo ufw --force enable


# Fail2ban
# https://www.lifewire.com/install-fail2ban-on-ubuntu-server-18-04-4179020

# Install Fail2ban
sudo apt-get update && sudo apt-get install --yes fail2ban

sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Configure Fail2ban
sudo sh -c "echo [sshd] > /etc/fail2ban/jail.local"
sudo sh -c "echo enabled = true >> /etc/fail2ban/jail.local"
sudo sh -c "echo port = 22 >> /etc/fail2ban/jail.local"
sudo sh -c "echo filter = sshd >> /etc/fail2ban/jail.local"
sudo sh -c "echo logpath = /var/log/auth.log >> /etc/fail2ban/jail.local"
sudo sh -c "echo maxretry = 3 >> /etc/fail2ban/jail.local"

# Restart Fail2ban
sudo systemctl restart fail2ban
