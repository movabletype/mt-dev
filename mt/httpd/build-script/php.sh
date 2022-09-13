#!/bin/sh -x

php_fpm_dirs="/etc/php-fpm.d"
php_fpm_d=`ls -d $php_fpm_dirs 2>/dev/null | head -1`

if [ -n "$php_fpm_d" ]; then
    cat > /etc/php-fpm.d/mt-env.conf <<CONF
[www]
env[NLS_LANG] = \$NLS_LANG
CONF
fi
