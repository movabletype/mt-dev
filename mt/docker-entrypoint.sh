#!/bin/sh

chmod 777 /var/www/html
chmod 777 /var/www/cgi-bin/mt/mt-static/support
chmod 777 /var/www/cgi-bin/mt/theme

if [ "$1" = "apache2-foreground" ]; then
    rm -f /var/log/apache2/access.log # disable access logging

    httpd_conf_d=`ls -d /etc/httpd/conf.d /etc/apache2/conf-enabled /etc/httpd/conf/extra 2>/dev/null | head -1`
    cat > $httpd_conf_d/mt.conf <<CONF
Timeout 3600

# mt-static
Alias /mt-static/ /var/www/cgi-bin/mt/mt-static/
CONF

    mod_rewrite_so=`find /usr/lib/apache2/modules /usr/lib64/httpd/modules /usr/lib/httpd/modules -name 'mod_rewrite.so' 2>/dev/null | head -1`
    if [ -n "$mod_rewrite_so" ]; then
        cat > $httpd_conf_d/mt-rewrite.conf <<CONF
LoadModule rewrite_module $mod_rewrite_so
CONF
    fi

    mod_proxy_so=`find /usr/lib/apache2/modules /usr/lib64/httpd/modules /usr/lib/httpd/modules -name 'mod_proxy.so' 2>/dev/null | head -1`
    if [ -n "$mod_proxy_so" ]; then
        cat > $httpd_conf_d/mt-proxy.conf <<CONF
LoadModule proxy_module $mod_proxy_so
ProxyPassReverse / http://mt/
CONF
    fi

    mod_proxy_http_so=`find /usr/lib/apache2/modules /usr/lib64/httpd/modules /usr/lib/httpd/modules -name 'mod_proxy_http.so' 2>/dev/null | head -1`
    if [ -n "$mod_proxy_http_so" ]; then
        cat > $httpd_conf_d/mt-proxy_http.conf <<CONF
LoadModule proxy_http_module $mod_proxy_http_so
ProxyPassReverse / http://mt/
CONF
    fi

    if [ $httpd_conf_d = "/etc/httpd/conf/extra" ]; then
        # archlinux
        cat >> /etc/httpd/conf/httpd.conf <<CONF
Include conf/extra/mt*.conf
CONF
    fi

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
    httpd_conf_d=`ls -d /etc/httpd/conf.d /etc/apache2/conf-enabled /etc/httpd/conf/extra 2>/dev/null | head -1`
    cat > $httpd_conf_d/mt.conf <<CONF
Timeout 3600
CONF

    mod_env_so=`find /usr/lib/apache2/modules /usr/lib64/httpd/modules /usr/lib/httpd/modules -name 'mod_env.so' 2>/dev/null | head -1`
    if [ -n "$mod_env_so" ]; then
        cat > $httpd_conf_d/mt-env.conf <<CONF
LoadModule env_module $mod_env_so
PassEnv NLS_LANG
CONF
    fi

    if [ "$MT_DEV_UPDATE_BRANCH" = "yes" -o "$MT_DEV_UPDATE_BRANCH" = "1" ] && [ -e "/var/www/cgi-bin/mt/Makefile" ]; then
        make -C /var/www/cgi-bin/mt clean me
    fi

    exec "$@"
fi
