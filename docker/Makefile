build:
	docker build -t movabletype/dev:buster  -t movabletype/dev:perl-5.28 buster
	docker build -t movabletype/dev:jessie  -t movabletype/dev:perl-5.20 jessie
	docker build -t movabletype/dev:centos6 -t movabletype/dev:perl-5.10 centos6
	docker build -t movabletype/dev:fedora  -t movabletype/dev:perl-5.30 fedora

push:
	for t in \
		movabletype/dev:buster  movabletype/dev:perl-5.28 \
		movabletype/dev:jessie  movabletype/dev:perl-5.20 \
		movabletype/dev:centos6 movabletype/dev:perl-5.10 \
		movabletype/dev:fedora  movabletype/dev:perl-5.30 \
	; do \
		docker push $$t; \
	done
