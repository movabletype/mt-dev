FROM php:5.5-apache

ADD core.conf /etc/apache2/conf-available/
ADD mt-static.conf /etc/apache2/conf-available/

RUN set -ex &&\
  \
  a2enmod rewrite proxy proxy_http &&\
  a2enconf core mt-static &&\
  docker-php-ext-install mysqli
