FROM movabletype/test:centos6

ADD mt-static.conf /etc/httpd/conf.d/mt-static.conf

RUN set -ex &&\
  \
  perl -i -pe \
    's{AllowOverride None}{AllowOverride All}g' \
    /etc/httpd/conf/httpd.conf

RUN set -ex &&\
  \
  cpm install -g Starman &&\
  rm -fr /root/.perl-cpm/
