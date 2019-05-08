#!/usr/bin/env bash

die () {
    echo >&2 "$@"
    exit 1
}

[[ "$#" -ge 2 ]] || die "usage: deploy.sh [staging | production] <domain1 domain2 ...> "


domains=(${@:2})


#bash scripts/host-setup.sh
#bash scripts/mount-transip-bigstorage.sh
#bash scripts/install-docker.sh
bash scripts/create-dummy-certificates.sh "${@:2}"

for domain in "${domains[@]}"; do
    echo "### $domain ..."
    sed "s/example.com/$domain/g" config/nginx/production/default.conf.template > "config/nginx/production/$domain.conf"
done

bash scripts/init-letsencrypt.sh "$1" "${@:2}"

sudo docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d --force-recreate
