build:
	docker build -t movabletype/dev:buster  -t movabletype/dev:perl-5.28 mt/buster
	docker build -t movabletype/dev:jessie  -t movabletype/dev:perl-5.20 -t movabletype/dev:php-5.6 mt/jessie
	docker build -t movabletype/dev:centos6 -t movabletype/dev:perl-5.10 -t movabletype/dev:php-5.3 mt/centos6
	docker build -t movabletype/dev:fedora  -t movabletype/dev:perl-5.30 -t movabletype/dev:php-7.3 mt/fedora
	for v in 5.4 5.5 7.1 7.2 7.4; do \
		docker build -t movabletype/dev:php-$$v php/$$v; \
	done
	docker build -t movabletype/dev:openldap ldap/openldap

push:
	for t in \
		movabletype/dev:buster  movabletype/dev:perl-5.28 \
		movabletype/dev:jessie  movabletype/dev:perl-5.20 \
		movabletype/dev:centos6 movabletype/dev:perl-5.10 \
		movabletype/dev:fedora  movabletype/dev:perl-5.30 \
		movabletype/dev:php-5.3 \
		movabletype/dev:php-5.4 \
		movabletype/dev:php-5.5 \
		movabletype/dev:php-5.6 \
		movabletype/dev:php-7.1 \
		movabletype/dev:php-7.2 \
		movabletype/dev:php-7.3 \
		movabletype/dev:php-7.4 \
		movabletype/dev:openldap \
	; do \
		docker push $$t; \
	done
