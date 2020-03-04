FROM php:7.4-apache

RUN set -ex &&\
  \
  a2enmod rewrite proxy proxy_http &&\
  docker-php-ext-install mysqli
