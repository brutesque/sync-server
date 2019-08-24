#!/usr/bin/env bash

# https://docs.docker.com/install/linux/docker-ce/ubuntu/
# https://docs.docker.com/install/linux/linux-postinstall/


# Install packages to allow apt to use a repository over HTTPS
sudo apt-get update && sudo apt-get install --yes \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching
# for the last 8 characters of the fingerprint.
FINGERPRINT_TEST=$(sudo apt-key fingerprint 0EBFCD88)
if [[ -z "$FINGERPRINT_TEST" ]]; then
    exit 1
fi

# Set up the stable repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

# Install the latest version of Docker CE and containerd
sudo apt-get update && sudo apt-get install --yes \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose

# Configure Docker to start on boot
sudo systemctl enable docker

# Create the docker group
sudo groupadd docker

# Add current user to the docker group
sudo usermod -aG docker $USER
