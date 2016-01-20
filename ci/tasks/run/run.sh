#!/bin/bash

set -ex

ip=$(ip route get 1 | awk '{print $NF;exit}')
damain=local.nanocf.io

echo "address=/$domain/$ip" > /etc/dnsmasq.d/domain
/etc/init.d/dnsmasq start

/var/micropcf/run "$domain"

cf api "api.$domain" --skip-ssl-validation
cf auth admin admin
cf target -o micropcf-org -s micropcf-space
cf push app -o cloudfoundry/lattice-app -m 32M

curl -v "http://app.${domain}"
