FROM perl:5.42-slim

ARG DOCKER_VERSION

RUN set -ex \
    \
    && apt-get update \
    && apt-get install -y curl gcc \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    ## docker
    && mkdir /tmp/docker \
    && cd /tmp/docker \
    && curl -sL https://download.docker.com/linux/static/stable/`arch`/docker-${DOCKER_VERSION}.tgz -o docker.tgz \
    && tar zxf docker.tgz \
    && mv docker/docker /usr/bin/docker \
    && rm -fr /tmp/docker \
    && cd \
    ## cpan libraries
    && cpanm --from https://www.cpan.org Filesys::Notify::Simple Linux::Inotify2 \
    && apt-get purge -y curl gcc
