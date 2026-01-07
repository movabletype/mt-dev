#!/bin/sh -x

conf_dirs="/etc/httpd/conf.d /etc/apache2/conf-enabled /etc/httpd/conf/extra"
module_dirs="/usr/lib/apache2/modules /usr/lib64/httpd/modules /usr/lib/httpd/modules"

rm -f /etc/apache2/sites-enabled/default-ssl.conf # disable ssl

mkdir -m 777 -p /tmp/apache2/log /tmp/apache2/run

httpd_conf_d=`ls -d $conf_dirs 2>/dev/null | head -1`
cat > $httpd_conf_d/mt.conf <<CONF
Timeout 3600

# mt-static
Alias /mt-static/ /var/www/cgi-bin/mt/mt-static/

# Workaround to run amd64 image on arm64
Mutex posixsem
CONF

mod_rewrite_so=`find $module_dirs -name 'mod_rewrite.so' 2>/dev/null | head -1`
if [ -n "$mod_rewrite_so" ]; then
    cat > $httpd_conf_d/mt-rewrite.conf <<CONF
LoadModule rewrite_module $mod_rewrite_so
CONF
fi

mod_proxy_so=`find $module_dirs -name 'mod_proxy.so' 2>/dev/null | head -1`
if [ -n "$mod_proxy_so" ]; then
    cat > $httpd_conf_d/mt-proxy.conf <<CONF
LoadModule proxy_module $mod_proxy_so
ProxyPreserveHost on
CONF
fi

mod_proxy_http_so=`find $module_dirs -name 'mod_proxy_http.so' 2>/dev/null | head -1`
if [ -n "$mod_proxy_http_so" ]; then
    cat > $httpd_conf_d/mt-proxy_http.conf <<CONF
LoadModule proxy_http_module $mod_proxy_http_so
ProxyPreserveHost on
CONF
fi

mod_include_so=`find $module_dirs -name 'mod_include.so' 2>/dev/null | head -1`
if [ -n "$mod_include_so" ]; then
    cat > $httpd_conf_d/mt-include.conf <<CONF
LoadModule include_module /usr/lib/apache2/modules/mod_include.so
<Directory /var/www/html>
<IfModule mod_include.c>
Options +Includes
AddOutputFilter INCLUDES .html
</IfModule>
</Directory>
CONF
fi

if [ $httpd_conf_d = "/etc/httpd/conf/extra" ]; then
    # archlinux
    cat >> /etc/httpd/conf/httpd.conf <<CONF
Include conf/extra/mt*.conf
CONF
fi

mod_env_so=`find $module_dirs -name 'mod_env.so' 2>/dev/null | head -1`
if [ -n "$mod_env_so" ]; then
    cat > $httpd_conf_d/mt-env.conf <<CONF
LoadModule env_module $mod_env_so
PassEnv NLS_LANG MT_CONFIG MT_HOME
CONF
fi
