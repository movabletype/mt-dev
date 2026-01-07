#!/bin/sh

conf_dirs="/etc/httpd/conf.d /etc/apache2/conf-enabled /etc/httpd/conf/extra"
module_dirs="/usr/lib/apache2/modules /usr/lib64/httpd/modules /usr/lib/httpd/modules"

rm -f /etc/apache2/sites-enabled/default-ssl.conf # disable ssl

mkdir -m 777 -p /tmp/apache2/log /tmp/apache2/run

httpd_conf_d=`ls -d $conf_dirs 2>/dev/null | head -1`
cat > $httpd_conf_d/mt.conf <<CONF
Timeout 3600
CONF

mod_env_so=`find $module_dirs -name 'mod_env.so' 2>/dev/null | head -1`
if [ -n "$mod_env_so" ]; then
    cat > $httpd_conf_d/mt-env.conf <<CONF
LoadModule env_module $mod_env_so
PassEnv NLS_LANG MT_CONFIG MT_HOME
CONF
fi
