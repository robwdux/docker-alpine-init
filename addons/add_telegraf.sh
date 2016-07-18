#!/bin/sh
set -o nounset -o errexit -o xtrace -o verbose

local SVC=telegraf
local URL=https://dl.influxdata.com/telegraf/releases
local CNF_DIR=/$SVC
local SRC_DIR=/usr/src/${SVC}
local BIN_DIR=/usr/local/bin/

mkdir -p $SRC_DIR $CNF_DIR
cd $SRC_DIR

gpg --keyserver hkp://ha.pool.sks-keyservers.net \
    --recv-keys 05CE15085FC09D18E99EFB22684A14CF2582E0C5

curl -fLO ${URL}/telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz.asc
curl -fLO ${URL}/telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz

gpg --batch --verify \
  telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz.asc \
  telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz

tar -zxvf telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz

chmod +x telegraf*/telegraf

mv -v telegraf*/telegraf $BIN_DIR

mv -v telegraf*/telegraf.conf $CNF_DIR

#
# service setup
#

local SGRP=$SVC
addgroup -S $SGRP
adduser -D -S -h ${CNF_DIR} -s /sbin/nologin -G $SGRP $SHGRP $SVC

# stage the service dir, symlink to enable

mkdir ${SVC_TDIR}/${SVC}

cp ${SVC_TDIR}/run ${SVC_TDIR}/${SVC}/run

# drop privs, use shared group otherwise service group

local GRP=${SHGRP:-${SGRP}}
local setuidgid="s6-setuidgid $(id -u ${SVC}):$(id -g ${GRP})"

echo "exec $setuidgid $SVC -config ${CNF_DIR}/telegraf.conf" \
  >> ${SVC_TDIR}/${SVC}/run
