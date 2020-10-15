#!/bin/sh

chmod 777 /var/www/html
chmod 777 /var/www/cgi-bin/mt/mt-static/support
chmod 777 /var/www/cgi-bin/mt/theme

if [ "$1" = "apache2-foreground" ]; then
    rm -f /var/log/apache2/access.log # disable access logging

    httpd_conf_d=`test -e /etc/httpd/conf.d && echo /etc/httpd/conf.d || echo '/etc/apache2/conf-enabled'`
    cat > $httpd_conf_d/mt.conf <<CONF
Timeout 3600

# mt-static
Alias /mt-static/ /var/www/cgi-bin/mt/mt-static/
CONF

    # invoke php-fpm
    if [ -e /usr/sbin/php-fpm ]; then
        mkdir /run/php-fpm
        /usr/sbin/php-fpm
    fi

    if [ -e /usr/local/bin/apache2-foreground ]; then
        exec /usr/local/bin/apache2-foreground
    else
        exec /usr/sbin/httpd -D FOREGROUND
    fi
else
    if [ -e "/var/www/cgi-bin/mt/Makefile" ]; then
        rm /var/www/cgi-bin/mt/build-language-stamp # remove cache file
        make -C /var/www/cgi-bin/mt me
    fi

    exec "$@"
fi
