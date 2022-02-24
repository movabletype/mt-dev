#!/bin/sh

if [ -n "$DOCKER_MT_SERVICES"  ]; then
    for s in $DOCKER_MT_SERVICES; do
        service $s start
    done
fi

if [ -n "$DOCKER_MT_CPANFILES"  ]; then
    for f in $DOCKER_MT_CPANFILES; do
        if [ -f $f ]; then
            cpm install -g --cpanfile=$f
        fi
    done
fi

chmod 777 /var/www/html
chmod 777 /var/www/cgi-bin/mt/mt-static/support
chmod 777 /var/www/cgi-bin/mt/themes

if [ "$1" = "apache2-foreground" ]; then
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
    if [ "$MT_DEV_UPDATE_BRANCH" = "yes" -o "$MT_DEV_UPDATE_BRANCH" = "1" ] && [ -e "/var/www/cgi-bin/mt/Makefile" ]; then
        make -C /var/www/cgi-bin/mt clean me
    fi

    exec "$@"
fi
