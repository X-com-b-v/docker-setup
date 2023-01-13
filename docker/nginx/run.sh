#!/usr/bin/env bash

XCOMUSER=$(cat /etc/xcomuser)

DEFAULT_PHP="7.4"
PROXYPORT="8888"


# handle media part, only for magento
handleMedia () {
    if [ -L "/data/shared/sites/$1/pub/media" ]; then
        # exit function if pub/media already is a symlink
        return
    fi
    if [ ! -d "/data/shared/media/$1" ]; then
        mkdir -p "/data/shared/media/$1"
        chown -R web.web $dir
    fi
    if [ -d "/data/shared/sites/$1/pub/media" ]; then
        mv /data/shared/sites/$1/pub/media/* /data/shared/media/$1/
        rm -rf /data/shared/sites/$1/pub/media
    fi
    ln -s /data/shared/media/$1 /data/shared/sites/$1/pub/media
    chown -R web.web /data/shared/sites/$1/pub/media
}

handleParams () {
    cat << EOF > "/data/shared/sites/$1/.siteconfig/params.conf.example"
fastcgi_param CONFIG__DEFAULT__WEB__UNSECURE__BASE_URL https://$1.$2.o.xotap.nl/;
fastcgi_param CONFIG__DEFAULT__WEB__SECURE__BASE_URL https://$1.$2.o.xotap.nl/;
fastcgi_param CONFIG__DEFAULT__WEB__UNSECURE__BASE_LINK_URL https://$1.$2.o.xotap.nl/;
fastcgi_param CONFIG__DEFAULT__WEB__SECURE__BASE_LINK_URL https://$1.$2.o.xotap.nl/;
fastcgi_param CONFIG__DEFAULT__WEB_COOKIE_COOKIE_DOMAIN $1.$2.o.xotap.nl;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__UNSECURE__BASE_URL https://$1.be.$2.o.xotap.nl/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__SECURE__BASE_URL https://$1.be.$2.o.xotap.nl/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__UNSECURE__BASE_LINK_URL https://$1.be.$2.o.xotap.nl/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__SECURE__BASE_LINK_URL https://$1.be.$2.o.xotap.nl/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB_COOKIE_COOKIE_DOMAIN $1.be.$2.o.xotap.nl;
EOF
}


rm /etc/nginx/sites-enabled/*
for d in `find -L /data/shared/sites -mindepth 1 -maxdepth 1 -type d`; do
    SITEBASENAME=`basename $d`

    if [ ! -d "/data/shared/sites/$SITEBASENAME/.siteconfig" ]; then
        mkdir -p /data/shared/sites/$SITEBASENAME/.siteconfig
        chown -R web.web /data/shared/sites/$SITEBASENAME/.siteconfig
    fi
    
    # check if logging dir exists
    if [ ! -d "/data/shared/sites/$SITEBASENAME/logs"  ]; then
        mkdir -p /data/shared/sites/$SITEBASENAME/logs
        chown -R web.web /data/shared/sites/$SITEBASENAME/logs
    fi

    HOSTFOUND="0"
    # example config file
    CONFIGFILE="/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"

    # default config
    CONFIG='{"template":"default","webserver":"nginx","php_protocol":"mod_php","php_version":"latest"}'

    if [ -f "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json" ]; then
        CONFIGFILE="/data/shared/sites/$SITEBASENAME/.siteconfig/config.json"
    elif [ -f "/data/shared/sites/$SITEBASENAME/bin/magento" ]; then
        # Lijkt op magento 2
        CONFIG='{"template":"magento2","webserver":"nginx","php_version":"7.4"}'
        handleParams "$SITEBASENAME" "$XCOMUSER"
        handleMedia "$SITEBASENAME"
    elif [ -d "/data/shared/sites/$SITEBASENAME/htdocs/wire" ]; then
        # Lijkt processwire
        CONFIG='{"template":"processwire","webserver":"nginx","php_protocol":"mod_php","php_version":"latest"}'
    elif [ -d "/data/shared/sites/$SITEBASENAME/htdocs/updateinfo" ]; then
        # Lijkt itix
        CONFIG='{"template":"default","webserver":"apache","php_protocol":"mod_php","php_version":"latest"}'
    elif [ -f "/data/shared/sites/$SITEBASENAME/app/etc/local.xml" ]; then
        # Lijkt op magento1
        CONFIG='{"template":"magento","webserver":"nginx","php_version":"7.0"}'
    elif [ -f "/data/shared/sites/$SITEBASENAME/bin/package.sh" ]; then
        # Lijkt op shopware
        CONFIG='{"template":"shopware","webserver":"nginx","php_version":"7.4"}'
    elif [ -f "/data/shared/sites/$SITEBASENAME/src/Kernel.php" ]; then
        # Lijkt symfony 4
        CONFIG='{"template":"symfony4","webserver":"nginx","php_version":"7.2"}'
    elif [ -f "/data/shared/sites/$SITEBASENAME/app/AppKernel.php" ]; then
        # Lijkt symfony
        CONFIG='{"template":"symfony","webserver":"nginx","php_version":"7.0"}'
    elif [ -d "/data/shared/sites/$SITEBASENAME/core/lib/Drupal/Core" ]; then
        # Lijkt drupal9
        CONFIG='{"template":"drupal","webserver":"nginx","php_version":"7.2"}'
    fi

    echo $CONFIG > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"

    USE_TEMPLATE=$(jq -r .template "$CONFIGFILE")
    USE_WEBSERVER=$(jq -r .webserver "$CONFIGFILE")
    USE_PHPPROTOCOL=$(jq -r .php_protocol "$CONFIGFILE")
    USE_PHPVERSION=$(jq -r .php_version "$CONFIGFILE")

    if [ "$USE_PHPVERSION" = "latest" ]; then
      USE_PHPVERSION="$DEFAULT_PHP"
    fi

    if ! [[ $USE_PHPVERSION =~ ^([0-9]+\.[0-9]+)$ ]]; then
      USE_PHPVERSION="$DEFAULT_PHP"
    fi

    INCLUDE_PARAMS=""
    if [ -f "/data/shared/sites/$SITEBASENAME/.siteconfig/params.conf" ]; then
        INCLUDE_PARAMS="include \/data\/shared\/sites\/$SITEBASENAME\/.siteconfig\/params.conf;"
    fi

    if [ -f "/data/shared/sites/$SITEBASENAME/.siteconfig/nginx.conf" ]; then
        # Custom nginx found, don't care what the config is, uses this one.
        cp /data/shared/sites/$SITEBASENAME/.siteconfig/nginx.conf /etc/nginx/sites-enabled/$SITEBASENAME.conf
    # https://stackoverflow.com/questions/43158140/way-to-create-multiline-comments-in-bash
    # : ' multi line comment because : is shorthand for true and does not process any params
    # we dont need other stuff like proxy as below
    elif [ "$USE_WEBSERVER" != "nginx" ]; then
        # if [ "$USE_WEBSERVER" = "apache" ]; then   
        # fi
        cp /etc/nginx/site-templates/proxy.conf /data/shared/sites/$SITEBASENAME/.siteconfig/nginx.conf.example
        cp /etc/nginx/site-templates/proxy.conf /etc/nginx/sites-enabled/$SITEBASENAME.conf
    
    else
        # webserver is nginx, check for custom template
        if [ "$USE_TEMPLATE" != "" ] && [ -f "/etc/nginx/site-templates/$USE_TEMPLATE.conf" ]; then
            cp "/etc/nginx/site-templates/$USE_TEMPLATE.conf" /data/shared/sites/$SITEBASENAME/.siteconfig/nginx.conf.example
            cp "/etc/nginx/site-templates/$USE_TEMPLATE.conf" /etc/nginx/sites-enabled/$SITEBASENAME.conf
        else
            cp /etc/nginx/site-templates/default.conf /data/shared/sites/$SITEBASENAME/.siteconfig/nginx.conf.example
            cp /etc/nginx/site-templates/default.conf /etc/nginx/sites-enabled/$SITEBASENAME.conf
        fi
    fi

    sed -i "s/##PROXYPORT##/$PROXYPORT/g" /etc/nginx/sites-enabled/$SITEBASENAME.conf
    sed -i "s/##USE_PHPVERSION##/$USE_PHPVERSION/g" /etc/nginx/sites-enabled/$SITEBASENAME.conf
    sed -i "s/##SITEBASENAME##/$SITEBASENAME/g" /etc/nginx/sites-enabled/$SITEBASENAME.conf
    sed -i "s/##XCOMUSER##/$XCOMUSER/g" /etc/nginx/sites-enabled/$SITEBASENAME.conf
    sed -i "s/##INCLUDE_PARAMS##/$INCLUDE_PARAMS/g" /etc/nginx/sites-enabled/$SITEBASENAME.conf
done

# configtest and restart
nginx -t
service nginx restart

if [ $? -eq 0 ];then
    tail -f /var/log/nginx/error.log
else
    tail -n 100 /var/log/nginx/error.log
    exit $?
fi
