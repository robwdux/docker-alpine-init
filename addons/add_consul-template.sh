#!/bin/sh
set -o nounset -o errexit -o xtrace -o verbose

local SVC=consul-template
local URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}
local CNF_DIR=/${SVC}
local SRC_DIR=/usr/src/${SVC}
local BIN_DIR=/usr/local/bin/

mkdir -p $SRC_DIR $CNF_DIR
cd $SRC_DIR

curl -fLO ${URL}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
curl -fLO ${URL}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS.sig
curl -fLO ${URL}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS

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

unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

chmod +x $SVC
mv $SVC $BIN_DIR

# create test template

echo "{{ (env $CONSUL_TEMPLATE_VERSION) }}" >> ${CNF_DIR}/test.ctmpl

#
# service setup
#

# create user and group(s) to drop/share privileges

local SGRP=$SVC
addgroup -S $SGRP
adduser -D -S -h ${CNF_DIR} -s /sbin/nologin -G $SGRP $SHGRP $SVC

# stage the service dir, symlink to enable

mkdir ${SVC_TDIR}/${SVC}

cp ${SVC_TDIR}/run ${SVC_TDIR}/${SVC}/run

# drop privs, use shared group otherwise service group

local GRP=${SHGRP:-${SGRP}}
local setuidgid="s6-setuidgid $(id -u ${SVC}):$(id -g ${GRP})"

# consul-template config options

local ctopt="-log-level \$CONSUL_TEMPLATE_LOG_LEVEL -consul \$CONSUL_AGENT"

# Actual template interpolates at runtime
echo "exec $setuidgid $SVC $ctopt -template \$CONSUL_TEMPLATE" \
  >> ${SVC_TDIR}/${SVC}/run
