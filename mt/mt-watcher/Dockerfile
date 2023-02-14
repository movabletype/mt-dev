FROM perl:5.36

ARG TARGETARCH
ARG DOCKER_VERSION=20.10.9

## docker
RUN set -ex \
    \
    && mkdir /tmp/docker \
    && cd /tmp/docker \
    && case "${TARGETARCH}" in arm64) platform=aarch64;; *) platform=x86_64;; esac \
    && curl -sL https://download.docker.com/linux/static/stable/${platform}/docker-${DOCKER_VERSION}.tgz -o docker.tgz \
    && tar zxf docker.tgz \
    && mv docker/docker /usr/bin/docker \
    && rm -fr /tmp/docker

## cpan libraries
RUN set -ex \
  \
  && cpanm Filesys::Notify::Simple Linux::Inotify2
