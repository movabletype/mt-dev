#!/bin/sh

[ -d /var/www/html/mt-static ] && rmdir /var/www/html/mt-static
[ -L /var/www/html/mt-static ] && rm /var/www/html/mt-static
ln -sf /var/www/cgi-bin/mt/mt-static /var/www/html/mt-static

chmod 777 /var/www/cgi-bin/mt/mt-static/support

exec "$@"
