FROM robwdux/alpine-base:3.4

MAINTAINER rob dux <robwdux@gmail.com>

ENTRYPOINT ["/init"]

WORKDIR /etc/services.d

ARG S6_VERSION
ARG ADD_CONSUL_TEMPLATE='false'
ARG CONSUL_TEMPLATE_VERSION

ENV S6_VERSION=${S6_VERSION:-1.18.1.3} \
    # do not reset container env
    S6_KEEP_ENV=1 \
    # log to stdout and stderr for all services
    S6_LOGGING=0 \
    # warn but continue if any stage 2 code fails
    S6_BEHAVIOUR_IF_STAGE2_FAILS=1 \
    SVC_DIR=/etc/services.d \
    SVC_TDIR=/etc/s6/svc-templates \
    # shared privilege group for services
    SHGRP='' \
    # addons - default enable if installed, allow disabling at runtime
    ADD_CONSUL_TEMPLATE='false' \
    ENABLE_CONSUL_TEMPLATE='true' \
    CONSUL_TEMPLATE_VERSION=${CONSUL_TEMPLATE_VERSION:-0.15.0} \
    CONSUL_TEMPLATE_DIR=/consul-template \
    CONSUL_DC=dc1 \
    CONSUL_AGENT=127.0.0.1:8500 \
    CONSUL_TEMPLATE_LOG_LEVEL=warn \
    CONSUL_TEMPLATE="/consul-template/test.ctmpl"

ENV PATH=${CONSUL_TEMPLATE_DIR}:$PATH

COPY ./addons/* /addons/

RUN set -o nounset -o errexit -o xtrace -o verbose \
    && apk add --no-cache --virtual .buildDeps gnupg unzip curl ca-certificates \
    && mkdir /usr/src && cd /usr/src \
    # install s6 init
    && curl -fLO \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz \
    && curl -fLO \
        https://github.com/just-containers/s6-overlay/releases/download/v1.18.1.3/s6-overlay-amd64.tar.gz.sig \
    && gpg --keyserver pgp.mit.edu --recv-key 0x337EE704693C17EF \
    && gpg --verify s6-overlay-amd64.tar.gz.sig s6-overlay-amd64.tar.gz \
    && tar -C / -zxf s6-overlay-amd64.tar.gz \
    # stage services, template scripts. symlink service to $SVC_DIR to enable
    && mkdir -p $SVC_TDIR \
    && { \
          echo "#!/bin/sh"; \
          echo "set -o nounset -o errexit -o xtrace -o verbose"; \
      } > ${SVC_TDIR}/run \
    && echo -e "#!/bin/sh\ns6-svscanctl -t /var/run/s6/services" \
        > ${SVC_TDIR}/finish.stop.containers \
    && chmod -R +x ${SVC_TDIR}/* \
    # are there any addons to install?
    && chmod +x /addons/* \
    && /addons/install-addons.sh \
    # purge
    && apk del --purge .buildDeps \
    && cd && rm -vrf /usr/src /root/* /tmp/*


# COMMIT - git show -s --format=%H
# DATE - git show -s --format=%cI
# AUTHOR - git show -s --format='"%an" <%ae>'
# URL - git ls-remote --get-url | sed -e "s|:|/|" -e s|git@|https://|"
ARG GIT_COMMIT=""
ARG GIT_COMMIT_DATE=""
ARG GIT_COMMIT_AUTHOR=""
ARG GIT_REPO_URL=""
