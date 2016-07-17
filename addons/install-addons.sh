#!/bin/sh

set -o nounset -o errexit -o xtrace -o verbose

cd /addons

[[ ADD_CONSUL_TEMPLATE ]] && ./add_consul-template.sh
