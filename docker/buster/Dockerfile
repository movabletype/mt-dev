FROM movabletype/test:buster

RUN set -ex &&\
  \
  apt-get update &&\
  DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes \
    apt-get --no-install-recommends -y install apache2 &&\
  apt-get clean &&\
  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* &&\
# invoke apache2 via /usr/bin/httpd
  ln -s /usr/sbin/apache2 /usr/sbin/httpd

ADD var-www.conf /etc/apache2/conf-available/
RUN set -ex &&\
  \
  a2dismod mpm_event &&\
  a2enmod mpm_prefork cgi php7.3 rewrite proxy proxy_http &&\
  a2disconf serve-cgi-bin &&\
  a2enconf var-www

RUN set -ex &&\
  \
  cpm install -g Starman &&\
  rm -fr /root/.perl-cpm/

ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid 
