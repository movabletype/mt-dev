FROM php:5.5-apache

RUN set -ex &&\
  \
  a2enmod rewrite proxy proxy_http &&\
  docker-php-ext-install mysqli
