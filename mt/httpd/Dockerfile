ARG DOCKER_HTTPD_IMAGE
FROM ${DOCKER_HTTPD_IMAGE}

COPY build-script/*.sh /tmp/build-script/
RUN for f in /tmp/build-script/*.sh; do \
        /bin/bash $f; \
    done \
    && rm -rf /tmp/build-script
