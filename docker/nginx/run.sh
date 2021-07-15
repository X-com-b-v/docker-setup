#!/bin/bash

XCOMUSER=$(cat /etc/xcomuser)

DEFAULT_PHP="7.3"

#if [ ! -d "/data/shared/sites/example" ]; then
#    mkdir /data/shared/sites/example
#fi

rm /etc/nginx/sites-enabled/*
for d in `find -L /data/shared/sites -mindepth 1 -maxdepth 1 -type d`; do
    SITEBASENAME=`basename $d`

    if [ ! -d "/data/shared/sites/$SITEBASENAME/.siteconfig" ]; then
        mkdir -p /data/shared/sites/$SITEBASENAME/.siteconfig
        chown -R web.web /data/shared/sites/$SITEBASENAME/.siteconfig
    fi

    if [ ! -d "/data/shared/sites/$SITEBASENAME/logs" ]; then
        mkdir -p /data/shared/sites/$SITEBASENAME/logs
    fi

    if [ ! -d "/data/shared/media/$SITEBASENAME" ]; then
        mkdir -p /data/shared/media/$SITEBASENAME
    fi

    HOSTFOUND="0"
    CONFIGFILE="/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"

    if [ -f "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json" ]; then
        CONFIGFILE="/data/shared/sites/$SITEBASENAME/.siteconfig/config.json"
    elif [ -f "/data/shared/sites/$SITEBASENAME/bin/magento" ]; then
        # Lijkt op magento 2
        echo '{"template":"magento2","webserver":"nginx","php_version":"7.3"}' > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"
        cat << EOF > "/data/shared/sites/$SITEBASENAME/.siteconfig/params.conf.example"
fastcgi_param CONFIG__DEFAULT__WEB__UNSECURE__BASE_URL https://customer.$XCOMUSER.o.xotap.nl/;
fastcgi_param CONFIG__DEFAULT__WEB__SECURE__BASE_URL https://customer.$XCOMUSER.o.xotap.nl/;
fastcgi_param CONFIG__DEFAULT__WEB__UNSECURE__BASE_LINK_URL https://customer.$XCOMUSER.o.xotap.nl/;
fastcgi_param CONFIG__DEFAULT__WEB__SECURE__BASE_LINK_URL https://customer.$XCOMUSER.o.xotap.nl/;
fastcgi_param CONFIG__DEFAULT__WEB_COOKIE_COOKIE_DOMAIN customer.$XCOMUSER.o.xotap.nl;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__UNSECURE__BASE_URL https://customer.be.$XCOMUSER.o.xotap.nl/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__SECURE__BASE_URL https://customer.be.$XCOMUSER.o.xotap.nl/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__UNSECURE__BASE_LINK_URL https://customer.be.$XCOMUSER.o.xotap.nl/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__SECURE__BASE_LINK_URL https://customer.be.$XCOMUSER.o.xotap.nl/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB_COOKIE_COOKIE_DOMAIN customer.be.$XCOMUSER.o.xotap.nl;
EOF

    elif [ -f "/data/shared/sites/$SITEBASENAME/app/etc/local.xml" ]; then
        # Lijkt op magento1
        echo '{"template":"magento","webserver":"nginx","php_version":"7.0"}' > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"
    elif [ -f "/data/shared/sites/$SITEBASENAME/bin/package.sh" ]; then
        # Lijkt op shopware
        echo '{"template":"shopware","webserver":"nginx","php_version":"7.4"}' > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"
    elif [ -f "/data/shared/sites/$SITEBASENAME/src/Kernel.php" ]; then
        # Lijkt symfony 4
        echo '{"template":"symfony4","webserver":"nginx","php_version":"7.2"}' > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"
    elif [ -f "/data/shared/sites/$SITEBASENAME/app/AppKernel.php" ]; then
        # Lijkt symfony
        echo '{"template":"symfony","webserver":"nginx","php_version":"7.0"}' > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"
    elif [ -d "/data/shared/sites/$SITEBASENAME/core/lib/Drupal/Core" ]; then
        # Lijkt drupal9
        echo '{"template":"drupal","webserver":"nginx","php_version":"7.2"}' > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"
    elif [ -d "/data/shared/sites/$SITEBASENAME/htdocs/wire" ]; then
        # Lijkt processwire
        echo '{"template":"processwire","webserver":"nginx","php_protocol":"mod_php","php_version":"latest"}' > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"\
    else
        # default hosting
        echo '{"template":"default","webserver":"nginx","php_protocol":"mod_php","php_version":"latest"}' > "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"
    fi

    # handle media part, only for magento
    handleMedia () {
        if [ -f "/data/shared/sites/$1/bin/magento" ]; then
            if [ ! -d "/data/shared/media/$1" ]; then
                mkdir -p "/data/shared/media/$1"
            fi
            chown -R web.web /data/shared/media/$1
            if [ -L "/data/shared/sites/$1/pub/media" ]; then
                # exit function if pub/media already is a symlink
                return
            fi
            if [ -d "/data/shared/sites/$1/pub/media" ]; then
                mv /data/shared/sites/$1/pub/media/* /data/shared/media/$1/
                rm -r /data/shared/sites/$1/pub/media
            fi
            ln -s /data/shared/media/$1 /data/shared/sites/$1/pub/media
            chown -R web.web /data/shared/sites/$1/pub/media
        fi
    }
    handleMedia "$SITEBASENAME"

    PROXYPORT=""
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
    : '
    elif [ "$USE_WEBSERVER" != "nginx" ]; then
        # Nginx is not needed, just forward traffic to next webserver

        # fallback to default apache server
        PROXYPORT="81"
        if [ "$USE_PHPPROTOCOL" = "fpm" ]; then
            # Forward to default apache server, apache config determines what php version
            PROXYPORT="81"
        elif [ "$USE_PHPPROTOCOL" = "mod_php" ]; then
            if [ "$USE_PHPVERSION" = "5.6" ]; then
                PROXYPORT="82"
            elif [ "$USE_PHPVERSION" = "7.0" ]; then
                PROXYPORT="83"
            elif [ "$USE_PHPVERSION" = "7.1" ]; then
                PROXYPORT="84"
            elif [ "$USE_PHPVERSION" = "7.2" ]; then
                PROXYPORT="85"
            elif [ "$USE_PHPVERSION" = "7.3" ]; then
                PROXYPORT="86"
            fi
        fi

        cp /etc/nginx/site-templates/proxy.conf /data/shared/sites/$SITEBASENAME/.siteconfig/nginx.conf.example
        cp /etc/nginx/site-templates/proxy.conf /etc/nginx/sites-enabled/$SITEBASENAME.conf
    '
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

/etc/init.d/nginx start
/etc/init.d/nginx status

if [ $? -eq 0 ];then
    tail -f /var/log/nginx/error.log
else
    tail -n 100 /var/log/nginx/error.log
    exit $?
fi
