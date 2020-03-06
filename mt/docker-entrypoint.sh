#!/bin/sh

chmod 777 /var/www/html
chmod 777 /var/www/cgi-bin/mt/mt-static/support

if [ "$1" = "apache2-foreground" ]; then
    rm -f /var/log/apache2/access.log # disable access logging

    if [ -e /usr/local/bin/apache2-foreground ]; then
        exec /usr/local/bin/apache2-foreground
    else
        exec /usr/sbin/httpd -D FOREGROUND
    fi
else
    exec "$@"
fi
