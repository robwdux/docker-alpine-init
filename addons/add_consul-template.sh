#!/bin/sh
set -o nounset -o errexit -o xtrace -o verbose

CT_URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}

mkdir -p /usr/src/consul-template/

curl -fLO ${CT_URL}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
curl -fLO ${CT_URL}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS.sig
curl -fLO ${CT_URL}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS

# Verify binary
# https://www.hashicorp.com/security.html

#gpg --keyserver pgp.mit.edu --recv-key 0xDCFB6F4EB24A6437
gpg --keyserver pgp.mit.edu --recv-key 51852D87348FFC4C
gpg --verify consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS.sig \
  consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS

grep consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64 SHA256SUMS \
  | sha256sum -c - \
  || {
    echo "consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip is corrupt";
    exit 1;
  }

unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -d /consul-template/

mkdir ${SVC_TDIR}/consul-template

# create user and group(s) to drop/share privileges

SGRP=consul-template
addgroup -S $SGRP
adduser -D -S -h ${CONSUL_TEMPLATE_DIR} -s /sbin/nologin -G $SGRP $SHGRP consul-template

# setup / stage the service dir, symlink to enable

cp ${SVC_TDIR}/run ${SVC_TDIR}/consul-template/run

# drop privs, use shared group otherwise service group

GRP=${SHGRP:-${SGRP}}
setuidgid="s6-setuidgid $(id -u consul-template):$(id -g ${GRP})"

# create test template

echo "{{ (env $CONSUL_TEMPLATE_VERSION) }}" >> /${CONSUL_TEMPLATE_DIR}/test.ctmpl

# consul-template config options

ctopt="-log-level \$CONSUL_TEMPLATE_LOG_LEVEL -consul \$CONSUL_AGENT"

echo "exec $setuidgid consul-template $ctopt -template $CONSUL_TEMPLATE" \
  >> ${SVC_TDIR}/consul-template/run
