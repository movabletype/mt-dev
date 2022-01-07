MAKEFILE_DIR=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))

export BASE_SITE_PATH=${MAKEFILE_DIR}/site
export DOCKER=docker
export DOCKER_COMPOSE=docker-compose
export DOCKER_COMPOSE_YML_MIDDLEWARES=-f ./mt/mysql.yml -f ./mt/memcached.yml
export UP_ARGS=-d
export MT_HOME_PATH=${MAKEFILE_DIR}/../movabletype
export UPDATE_BRANCH=yes

MT_CONFIG_CGI=${shell [ -e mt-config.cgi ] && echo mt-config.cgi || echo mt-config.cgi-original}
BASE_ARCHIVE_PATH=${MAKEFILE_DIR}/archive

# shortcuts.
ifneq (${PHP},)
DOCKER_HTTPD_IMAGE=movabletype/test:php-${PHP}
endif
ifneq (${PERL},)
DOCKER_MT_IMAGE=movabletype/test:perl-${PERL}
endif
ifneq (${DB},)
DOCKER_MYSQL_IMAGE=${DB}
endif

export DOCKER_MT_BUILD_CONTEXT
export DOCKER_MT_IMAGE
export DOCKER_MT_SERVICES
export DOCKER_HTTPD_IMAGE
export DOCKER_MYSQL_IMAGE
export DOCKER_MEMCACHED_IMAGE
export DOCKER_LDAP_IMAGE
export DOCKER_FTPD_IMAGE
export DOCKER_VOLUME_MOUNT_FLAG
export MT_RUN_VIA
export HTTPD_EXPOSE_PORT
export PLACKUP
export CMD

# mt-watcher container
export DISABLE_MT_WATCHER
export PERL_FNS_NO_OPT


# override variables
ENV_FILE=.env
-include ${MAKEFILE_DIR}/${ENV_FILE}


# setup internal variables

MT_CONFIG_CGI_SRC_PATH=${shell perl -e 'print("${MT_CONFIG_CGI}" =~ m{/} ? "${MT_CONFIG_CGI}" : "${MAKEFILE_DIR}/${MT_CONFIG_CGI}")' }
export MT_CONFIG_CGI_SRC_PATH

ifneq (${WITHOUT_MT_CONFIG_CGI},)
export MT_CONFIG_CGI_DEST_PATH=/tmp/mt-config.cgi
endif

ifeq ($(wildcard ${MT_CONFIG_CGI_SRC_PATH}),)
$(error You should create ${MT_CONFIG_CGI_SRC_PATH} first.)
endif

_DC=${DOCKER_COMPOSE} -f ./mt/common.yml ${DOCKER_COMPOSE_YML_MIDDLEWARES}


.PHONY: db up down

up: up-cgi

fixup:
	@perl -e 'exit($$ENV{MT_HOME_PATH} =~ m{/})' || \
		for f in mt-config.cgi mt-tb.cgi mt-comment.cgi .htaccess; do \
			fp=${MT_HOME_PATH}/$$f; \
			[ -d $$fp ] && rmdir $$fp || true; \
			[ -f $$fp ] && perl -e 'exit((stat(shift))[7] == 0 ? 0 : 1)' $$fp && rm -f $$fp || true; \
		done

setup-mysql-volume:
	$(eval export DOCKER_MYSQL_VOLUME=$(shell echo ${DOCKER_MYSQL_IMAGE} | sed -e 's/\..*//; s/[^a-zA-Z0-9]//g'))


ifneq (${SQL},)
MYSQL_COMMAND_ARGS=-e '${SQL}'
endif

exec-mysql:
	opt=""; if ! [ -t 0 ] ; then opt="-T" ; fi; \
		${_DC} exec $$opt db mysql -uroot -ppassword -h127.0.0.1 ${MYSQL_COMMAND_ARGS}

# FIXME:
exec-ldappasswd:
	${_DC} exec ldap ldappasswd -x -D "cn=admin,dc=example,dc=com" -w secret "cn=Melody,ou=users,dc=example,dc=com" -S


up-cgi: MT_RUN_VIA=cgi
up-cgi: up-common

up-psgi: MT_RUN_VIA=psgi
up-psgi: up-common


ifeq (${RECIPE},)
ARCHIVE_FOR_SETUP=""
else
ARCHIVE_FOR_SETUP=${ARCHIVE}
endif

up-common: down fixup
	${MAKE} down-mt-home-volume
	${DOCKER} volume create --label mt-dev-mt-home-tmp mt-dev-mt-home-tmp

ifneq (${ARCHIVE},)
ifeq (${RECIPE},)
	# TBD: random name?
	$(eval MT_HOME_PATH=mt-dev-mt-home-tmp)
	${MAKEFILE_DIR}/bin/extract-archive ${BASE_ARCHIVE_PATH} ${MT_HOME_PATH} $(shell echo ${ARCHIVE} | tr ',' ' ')
endif
endif

	$(eval export _ARGS=$(shell UPDATE_BRANCH=${UPDATE_BRANCH} ${MAKEFILE_DIR}/bin/setup-environment --recipe "$(shell echo ${RECIPE} | tr ',' ' ')" --repo "$(shell echo ${REPO} | tr ',' ' ')" --pr "$(shell echo ${PR} | tr ',' ' ')" --archive "$(shell echo ${ARCHIVE_FOR_SETUP} | tr ',' ' ')"))
ifneq (${RECIPE},)
	@perl -e 'exit(length($$ENV{_ARGS}) > 0 ? 0 : 1)'
endif
ifneq (${REPO},)
	@perl -e 'exit(length($$ENV{_ARGS}) > 0 ? 0 : 1)'
endif
ifneq (${PR},)
	@perl -e 'exit(length($$ENV{_ARGS}) > 0 ? 0 : 1)'
endif
	${MAKE} up-common-invoke-docker-compose MT_HOME_PATH=${MT_HOME_PATH} ${_ARGS} RECIPE="" REPO="" PR="" $(shell [ -n "${DOCKER_MT_IMAGE}" ] && echo "DOCKER_MT_IMAGE=${DOCKER_MT_IMAGE}") $(shell [ -n "${DOCKER_MYSQL_IMAGE}" ] && echo "DOCKER_MYSQL_IMAGE=${DOCKER_MYSQL_IMAGE}")

up-common-invoke-docker-compose: setup-mysql-volume
	@echo MT_HOME_PATH=${MT_HOME_PATH}
	@echo BASE_SITE_PATH=${BASE_SITE_PATH}
	@echo DOCKER_MT_IMAGE=${DOCKER_MT_IMAGE}
	@echo DOCKER_HTTPD_IMAGE=${DOCKER_HTTPD_IMAGE}
	@echo DOCKER_MYSQL_IMAGE=${DOCKER_MYSQL_IMAGE}
	${_DC} -f ./mt/${MT_RUN_VIA}.yml ${DOCKER_COMPOSE_YML_OVERRIDE} pull
	${_DC} -f ./mt/${MT_RUN_VIA}.yml ${DOCKER_COMPOSE_YML_OVERRIDE} build
	${_DC} -f ./mt/${MT_RUN_VIA}.yml ${DOCKER_COMPOSE_YML_OVERRIDE} up ${UP_ARGS}


ifneq (${REMOVE_VOLUME},)
DOWN_ARGS=-v
endif

down:
	${_DC} down --remove-orphans ${DOWN_ARGS}
	${MAKEFILE_DIR}/bin/teardown-environment
	${MAKE} down-mt-home-volume

down-mt-home-volume:
	@for v in `docker volume ls -f label=mt-dev-mt-home-tmp | sed -e '1d' | awk '{print $$2}'`; do \
		docker volume rm $$v; \
	done


clean-config:
	rm ~/.mt-dev.conf

clean-image: down
	${DOCKER} images | grep movabletype | awk '{ print $$3 }' | xargs ${DOCKER} rmi -f

docker-compose:
	${_DC} ${ARGS}


# aliases

logs: ARGS=logs
logs: docker-compose

ifeq (${CMD},)
mt-shell: ARGS=exec mt /bin/bash
mt-shell: docker-compose
else
mt-shell:
	${_DC} exec -e CMD mt /bin/bash -c "$$CMD"
endif

cpan-install:
	${_DC} exec mt cpm install -g ${ARGS}
	${_DC} exec mt kill 1

cpan-uninstall:
	${_DC} exec mt bash -c "cpm install -g App::cpanminus && cpanm -fU ${ARGS}"
	${_DC} exec mt kill 1

cp-R:
	mkdir -p ${TO}
	${_DC} exec -T mt tar -C ${FROM} -zcf - . | tar -C ${TO} -zxf -


build:
	${MAKE} -C docker
