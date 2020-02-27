MAKEFILE_DIR=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))

export BASE_SITE_PATH=${MAKEFILE_DIR}/../site
export DOCKER_COMPOSE_YML_MIDDLEWARE=-f ./mt/mysql.yml -f ./mt/memcached.yml
export DOCKER_COMPOSE_UP_OPT=-d
export MT_CONFIG_CGI=${MAKEFILE_DIR}/${shell [ -e mt-config.cgi ] && echo mt-config.cgi || echo mt-config.cgi-original}

WITHOUT_MT_CONFIG_CGI=
ifneq (${WITHOUT_MT_CONFIG_CGI},)
export MT_CONFIG_CGI_DEST_PATH=/tmp/mt-config.cgi
endif

export DOCKER_MT_IMAGE
export DOCKER_MYSQL_IMAGE
export MT_HOME_PATH
export MT_RUN_VIA

BASE_PACKAGE_PATH=${MAKEFILE_DIR}/package

.PHONY: db up down

up: up-cgi

init-repo:
	@cd .. ; \
		[ -d movabletype ] || \
			git clone git@github.com:movabletype/movabletype;

fixup:
	@for f in mt-config.cgi mt-tb.cgi mt-comment.cgi; do \
		fp=../movabletype/$$f; \
		[ -d $$fp ] && rmdir $$fp || true; \
		[ -f $$fp ] && [ `wc -c < $$fp` -eq "0" ] && rm -f $$fp || true; \
	done

setup-mysql-volume:
	$(eval export DOCKER_MYSQL_VOLUME=$(shell echo ${DOCKER_MYSQL_IMAGE} | sed -e 's/\..*//; s/[^a-zA-Z0-9]//g'))


ifneq (${SQL},)
MYSQL_COMMAND_OPT=-e '${SQL}'
endif

exec-mysql:
	docker-compose -f ./mt/common.yml ${DOCKER_COMPOSE_YML_MIDDLEWARE} exec db mysql -uroot -ppassword -h127.0.0.1 ${MYSQL_COMMAND_OPT}

up-cgi: MT_RUN_VIA=cgi
up-cgi: up-common

up-psgi: MT_RUN_VIA=psgi
up-psgi: up-common

up-common:
ifeq (${RECIPE},)
	${MAKE} up-common-without-recipe
else
	${MAKE} up-common-with-recipe
endif

up-common-without-recipe:
ifneq (${PACKAGE},)
	$(eval MT_HOME_PATH = $(shell mktemp -d -t mt-dev.XXXXXXXXXX))
	chmod 777 ${MT_HOME_PATH}
	@cd ${MT_HOME_PATH} && tar zxf ${BASE_PACKAGE_PATH}/${PACKAGE} || unzip ${BASE_PACKAGE_PATH}/${PACKAGE}
	mv ${MT_HOME_PATH}/*/* ${MT_HOME_PATH}
endif
	${MAKE} up-common-invoke-docker-compose

up-common-invoke-docker-compose: down init-repo fixup setup-mysql-volume
	@echo MT_HOME_PATH=${MT_HOME_PATH}
	@echo BASE_SITE_PATH=${BASE_SITE_PATH}
	@echo DOCKER_MT_IMAGE=${DOCKER_MT_IMAGE}
	@echo DOCKER_MYSQL_IMAGE=${DOCKER_MYSQL_IMAGE}
	@echo DOCKER_MYSQL_VOLUME=${DOCKER_MYSQL_VOLUME}
	docker-compose -f ./mt/common.yml -f ./mt/${MT_RUN_VIA}.yml ${DOCKER_COMPOSE_YML_MIDDLEWARE} ${DOCKER_COMPOSE_YML_OVERRIDE} up ${DOCKER_COMPOSE_UP_OPT}

up-common-with-recipe:
	$(eval OPTS=$(shell ./bin/setup-environment ${RECIPE}))
	[ `echo -n ${OPTS} | wc -c | sed -e 's/ *//'` -gt 10 ]
	${MAKE} ${OPTS} RECIPE="" $(shell [ -n "${DOCKER_MT_IMAGE}" ] && echo "DOCKER_MT_IMAGE=${DOCKER_MT_IMAGE}") $(shell [ -n "${DOCKER_MYSQL_IMAGE}" ] && echo "DOCKER_MYSQL_IMAGE=${DOCKER_MYSQL_IMAGE}")


ifneq (${REMOVE_VOLUME},)
DOWN_COMMAND_OPT=-v
endif

down:
	docker-compose -f ./mt/common.yml ${DOCKER_COMPOSE_YML_MIDDLEWARE} down ${DOWN_COMMAND_OPT}

build:
	${MAKE} -C docker
