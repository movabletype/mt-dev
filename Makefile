MAKEFILE_DIR=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))

export BASE_SITE_PATH:=${MAKEFILE_DIR}/site
export DOCKER:=docker
export DOCKER_COMPOSE:=${shell ${DOCKER} compose >/dev/null 2>&1 && echo 'docker compose' || echo 'docker-compose'}
export DOCKER_COMPOSE_YAML_MIDDLEWARES:=-f ./mt/mysql.yml -f ./mt/memcached.yml
export UP_ARGS:=-d
export MT_HOME_PATH:=${MAKEFILE_DIR}/../movabletype
export HTTPD_HOST_NAME:=localhost
export HTTPD_EXPOSE_PORT:=80
export UPDATE_BRANCH:=yes
export UPDATE_DOCKER_IMAGE:=yes
export CREATE_DATABASE_IF_NOT_EXISTS:=yes
export DOCKER_MT_CPANFILES:=t/cpanfile

MT_CONFIG_CGI=${shell [ -e mt-config.cgi ] && echo mt-config.cgi || echo mt-config.cgi-original}
BASE_ARCHIVE_PATH=${MAKEFILE_DIR}/archive

# shortcuts.
ifneq (${PHP},)
DOCKER_HTTPD_IMAGE=movabletype/test:php-${PHP}
endif
ifneq (${PERL},)
DOCKER_MT_IMAGE=movabletype/test:perl-${PERL}
endif
ifneq (${NODE},)
DOCKER_NODEJS_IMAGE=node:${NODE}
endif
ifneq (${DB},)
DOCKER_MYSQL_IMAGE=${DB}
endif
ifneq (${MT_EXPOSE_PORT},)
export DOCKER_COMPOSE_YAML_EXPOSE=-f ./mt/mt-expose.yml
endif

export DOCKER_COMPOSE_USER_YAML
export DOCKER_MT_BUILD_CONTEXT
export DOCKER_MT_DOCKERFILE
export DOCKER_MT_IMAGE
export DOCKER_MT_SERVICES
export DOCKER_MT_CPANFILES
export DOCKER_NODEJS_IMAGE
export DOCKER_HTTPD_BUILD_CONTEXT
export DOCKER_HTTPD_DOCKERFILE
export DOCKER_HTTPD_IMAGE
export DOCKER_MYSQL_IMAGE
export DOCKER_MYSQL_COMMAND
export DOCKER_MEMCACHED_IMAGE
export DOCKER_LDAP_IMAGE
export DOCKER_FTPD_IMAGE
export DOCKER_MAILPIT_IMAGE
export DOCKER_VOLUME_MOUNT_FLAG
export MT_RUN_VIA
export MT_EXPOSE_PORT
export MT_UID
export MAILPIT_EXPOSE_PORT
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

_DC=${DOCKER_COMPOSE} -f ./mt/common.yml ${DOCKER_COMPOSE_YAML_MIDDLEWARES} ${_DC_YAML_OVERRIDE} ${DOCKER_COMPOSE_YAML_EXPOSE} ${DOCKER_COMPOSE_USER_YAML}
_DATABASE=${shell perl -ne 'print $$1 if /^Database\s+([\w-]+)/' < ${MT_CONFIG_CGI_SRC_PATH}}

.PHONY: db up down

up: up-cgi

fixup:
	@perl -e 'exit($$ENV{MT_HOME_PATH} =~ m{/})' || \
		for f in mt-config.cgi mt-tb.cgi mt-comment.cgi .htaccess; do \
			fp=${MT_HOME_PATH}/$$f; \
			[ -d $$fp ] && rmdir $$fp || true; \
			[ -f $$fp ] && perl -e 'exit((stat(shift))[7] == 0 ? 0 : 1)' $$fp && rm -f $$fp || true; \
		done
	@chmod -R go-w mt/mysql/conf.d

setup-mysql-volume:
	$(eval export DOCKER_MYSQL_VOLUME=$(shell echo ${DOCKER_MYSQL_IMAGE} | sed -e 's/\..*//; s/[^a-zA-Z0-9]//g'))
	$(eval export DOCKER_MYSQL_COMMAND_AUTH_PLUGIN=$(shell if ! echo ${DOCKER_MYSQL_IMAGE} | egrep -q '^mysql:(9|[1-9][0-9]+)$$'; then echo '--default-authentication-plugin=mysql_native_password'; fi))

ifneq (${SQL},)
MYSQL_COMMAND_ARGS=-e '${SQL}'
endif

update-ssl:
	${DOCKER} run --rm -v ${MAKEFILE_DIR}/ssl:/ssl -w /ssl --entrypoint /bin/sh alpine/openssl:latest generate-certs.sh

exec-mysql:
	opt=""; if ! [ -t 0 ] ; then opt="-T" ; fi; \
		${_DC} exec $$opt db mysql -uroot -ppassword -hlocalhost ${MYSQL_COMMAND_ARGS}

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

up-common: down fixup update-ssl
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
	@if [ -t 1 ] && which tput >/dev/null 2>&1 && [ $$(tput colors 2>/dev/null || echo 0) -ge 8 ]; then \
		echo "\n\033[32m➜\033[0m Movable Type is running on http://${HTTPD_HOST_NAME}:${HTTPD_EXPOSE_PORT}/cgi-bin/mt/mt.cgi"; \
	else \
		echo "\n➜ Movable Type is running on http://${HTTPD_HOST_NAME}:${HTTPD_EXPOSE_PORT}/cgi-bin/mt/mt.cgi"; \
	fi

up-common-invoke-docker-compose: _DC_YAML_OVERRIDE=-f ./mt/${MT_RUN_VIA}.yml ${DOCKER_COMPOSE_YAML_OVERRIDE}
up-common-invoke-docker-compose: setup-mysql-volume
	@echo MT_HOME_PATH=${MT_HOME_PATH}
	@echo BASE_SITE_PATH=${BASE_SITE_PATH}
	@echo DOCKER_MT_IMAGE=${DOCKER_MT_IMAGE}
	@echo DOCKER_HTTPD_IMAGE=${DOCKER_HTTPD_IMAGE}
	@echo DOCKER_MYSQL_IMAGE=${DOCKER_MYSQL_IMAGE}
ifeq (${UPDATE_DOCKER_IMAGE},yes)
	${_DC} pull
	${_DC} build --pull
endif
ifeq (${CREATE_DATABASE_IF_NOT_EXISTS},yes)
ifneq (${_DATABASE},)
	${_DC} up -d db
	@while ! ${MAKE} exec-mysql MYSQL_COMMAND_ARGS="-e 'SELECT 1'" >/dev/null 2>&1; do \
		sleep 1; \
	done
	${MAKE} exec-mysql MYSQL_COMMAND_ARGS="-e 'CREATE DATABASE IF NOT EXISTS \`${_DATABASE}\` /* DEFAULT CHARACTER SET utf8mb4 */;'"
endif
endif
	${_DC} up ${UP_ARGS}


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

CODE_CPANM=$(shell type cpm >/dev/null 2>&1 && echo "cpm install" || echo "cpanm --installdeps .")
CODE_WORKSPACES_DIR=$(abspath ${MAKEFILE_DIR}/..)
CODE_DIR=${MAKEFILE_DIR}/.code
CODE_CODE_WORKSPACE_FILE=${CODE_DIR}/mt.code-workspace

code-init:
	mkdir -p ${CODE_DIR}

LIBS=$(shell \
	find .. -maxdepth 4 -type d \
		\( -name 'lib' -o -name 'extlib' \) \
		-not -path '*/node_modules/*' \
		-not -path '*/bower_components/*' \
		-not -path '*/local/*' \
		-not -path '*/.*/*' \
	| sed -e 's/^..\///' | grep -v 'movabletype-patches')
code-generate-workspace: code-init
	echo '{"folders":[' > ${CODE_CODE_WORKSPACE_FILE}
	for d in `echo ${LIBS} | perl -pe 's/\/\S+//g; s/ /\\n/g' | sort -u`; do \
		printf '%s%s%s' '{"path":"' ${CODE_WORKSPACES_DIR}/$$d '"},' >> ${CODE_CODE_WORKSPACE_FILE}; \
	done
	echo '],"settings":{"perlnavigator.includePaths":["${CODE_DIR}/local/lib/perl5",' >> ${CODE_CODE_WORKSPACE_FILE}
	for d in ${LIBS}; do \
		printf '%s%s%s' '"' ${CODE_WORKSPACES_DIR}/$$d '",' >> ${CODE_CODE_WORKSPACE_FILE}; \
	done
	echo ']}' >> ${CODE_CODE_WORKSPACE_FILE}

code-cpanm-install: code-init
	cd `ls -d ../*movabletype/t | head -n 1` && ${CODE_CPANM} -L${CODE_DIR}/local || true

code-open-workspace: code-cpanm-install code-generate-workspace
	code ${CODE_CODE_WORKSPACE_FILE}
