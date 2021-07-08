FROM ubuntu

RUN set -ex \
  \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -y install \
    inotify-tools docker.io \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
