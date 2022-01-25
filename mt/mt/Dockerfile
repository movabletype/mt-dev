ARG DOCKER_MT_IMAGE
FROM ${DOCKER_MT_IMAGE}

COPY build-script/*.sh /tmp/build-script/
RUN /bin/bash /tmp/build-script/apache2.sh \
    && rm -rf /tmp/build-script
