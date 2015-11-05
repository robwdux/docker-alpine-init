FROM robwdux/docker-alpine-base

MAINTAINER rob dux <robwdux@gmail.com>

ENV S6_VERSION=1.16.0.0 \
    SRV_TMPLT_DIR=/etc/s6/svc-templates \
    SRV_DIR=/etc/services.d

RUN set -o nounset -o errexit -o xtrace -o verbose && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz \
      | tar -zxf - -C / && \
    mkdir -p $SRV_TMPLT_DIR && \
    echo "#!/usr/bin/with-contenv sh" \
      > ${SRV_TMPLT_DIR}/run.container.env && \
    echo -e "#!/bin/sh\ns6-svscanctl -t /var/run/s6/services" \
      > ${SRV_TMPLT_DIR}/finish.container.stop && \
    chmod -R +x ${SRV_TMPLT_DIR}/*

ENTRYPOINT ["/init"]
