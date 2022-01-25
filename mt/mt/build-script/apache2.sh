#!/bin/sh

conf_dirs="/etc/httpd/conf.d /etc/apache2/conf-enabled /etc/httpd/conf/extra"
module_dirs="/usr/lib/apache2/modules /usr/lib64/httpd/modules /usr/lib/httpd/modules"

httpd_conf_d=`ls -d $conf_dirs 2>/dev/null | head -1`
cat > $httpd_conf_d/mt.conf <<CONF
Timeout 3600
CONF

mod_env_so=`find $module_dirs -name 'mod_env.so' 2>/dev/null | head -1`
if [ -n "$mod_env_so" ]; then
    cat > $httpd_conf_d/mt-env.conf <<CONF
LoadModule env_module $mod_env_so
PassEnv NLS_LANG
CONF
fi
