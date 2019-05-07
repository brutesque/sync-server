#!/usr/bin/env bash

die () {
    echo >&2 "$@"
    exit 1
}

[[ "$#" -ge 2 ]] || die "usage: init-letsencrypt.sh [staging | production] <domain1 domain2 ...> "


domains=(${@:2})
rsa_key_size=4096
data_path="./config/certbot"
email="" # Adding a valid address is strongly recommended

if [[ -d "$data_path/conf/live/" ]]; then
    read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
    if [[ "$decision" != "Y" ]] && [[ "$decision" != "y" ]]; then
        exit
    fi
fi

echo "### Starting nginx ..."
sudo docker-compose -f docker-compose.yml -f docker-compose.production.yml up --force-recreate --no-deps -d nginx
echo

for domain in "${domains[@]}"; do
  echo "### Deleting dummy certificate for $domains ..."
  sudo docker-compose -f docker-compose.yml -f docker-compose.production.yml run --rm --entrypoint "\
    rm -Rf /etc/letsencrypt/live/$domain" certbot
  echo
done

echo "### Requesting Let's Encrypt certificate for $domains ..."

# Select appropriate email arg
case "$email" in
    "") email_arg="--register-unsafely-without-email" ;;
    *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [[ $1 != "production" ]]; then staging_arg="--staging"; fi

for domain in "${domains[@]}"; do
    sudo docker-compose -f docker-compose.yml -f docker-compose.production.yml run --rm --no-deps --entrypoint "\
        certbot certonly --webroot -w /var/www/certbot \
        $staging_arg \
        $email_arg \
        -d $domain \
        --rsa-key-size $rsa_key_size \
        --agree-tos \
        --force-renewal" certbot
    echo
done

echo "### Stopping nginx ..."
sudo docker-compose down
