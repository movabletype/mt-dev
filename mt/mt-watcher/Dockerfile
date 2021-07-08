FROM perl:5.34

ENV DOCKER_VERSION=20.10.7

## docker
RUN set -ex \
    \
    && mkdir /tmp/docker \
    && cd /tmp/docker \
    && curl -sL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz -o docker.tgz \
    && tar zxf docker.tgz \
    && mv docker/docker /usr/bin/docker \
    && rm -fr /tmp/docker

## cpan libraries
RUN set -ex \
  \
  && cpanm Filesys::Notify::Simple Linux::Inotify2
