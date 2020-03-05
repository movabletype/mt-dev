FROM php:7.1-apache

ADD mt-static.conf /etc/apache2/conf-available/

RUN set -ex &&\
  \
  a2enmod rewrite proxy proxy_http &&\
  a2enconf mt-static &&\
  docker-php-ext-install mysqli
