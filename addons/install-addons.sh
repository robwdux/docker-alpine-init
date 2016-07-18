#!/bin/sh

set -o nounset -o errexit -o xtrace -o verbose

cd /addons

[[ $ADD_CONSUL_TEMPLATE == true ]] && ./add_consul-template.sh || true

[[ $ADD_TELEGRAF == true ]] && ./add_telegraf.sh || true
