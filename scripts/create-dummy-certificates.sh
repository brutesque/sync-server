#!/usr/bin/env bash

die () {
    echo >&2 "$@"
    exit 1
}

[[ "$#" -ge 1 ]] || die "usage: init-letsencrypt.sh <domain1 domain2 ...> "


domains=(${@:1})
rsa_key_size=4096
data_path="./config/certbot"

if [[ -d "$data_path/conf/live/" ]]; then
    read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
    if [[ "$decision" != "Y" ]] && [[ "$decision" != "y" ]]; then
        exit
    fi
fi

if [[ ! -e "$data_path/conf/options-ssl-nginx.conf" ]] || [[ ! -e "$data_path/conf/ssl-dhparams.pem" ]]; then
    echo "### Downloading recommended TLS parameters ..."
    mkdir -p "$data_path/conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
    echo
fi

for domain in "${domains[@]}"; do
    echo "### Creating dummy certificate for $domain ..."
    path="/etc/letsencrypt/live/$domain"
    mkdir -p "$data_path/conf/live/$domain"
    sudo docker-compose -f docker-compose.yml -f docker-compose.production.yml run --rm --no-deps --entrypoint "\
        openssl req -x509 -nodes -newkey rsa:'$rsa_key_size' -days 1\
        -keyout '$path/privkey.pem' \
        -out '$path/fullchain.pem' \
        -subj '/CN=localhost'" certbot
    echo
done
