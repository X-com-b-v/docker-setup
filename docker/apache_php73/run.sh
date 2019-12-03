#!/bin/bash

XCOMUSER=$(cat /etc/xcomuser)

USE_PORT=86
THIS_PHPPROTOCOL="mod_php"
THIS_PHPVERSION="7.3"

rm /etc/apache2/sites-enabled/*
for d in `find -L /data/shared/sites -mindepth 1 -maxdepth 1 -type d`; do
    SITEBASENAME=`basename $d`

    CONFIGFILE="/data/shared/sites/$SITEBASENAME/.siteconfig/config.json.example"

    if [ -f "/data/shared/sites/$SITEBASENAME/.siteconfig/config.json" ]; then
        CONFIGFILE="/data/shared/sites/$SITEBASENAME/.siteconfig/config.json"
    fi

    if [ ! -f "$CONFIGFILE" ]; then
        continue;
    fi

    USE_TEMPLATE=$(jq -r .template "$CONFIGFILE")
    USE_WEBSERVER=$(jq -r .webserver "$CONFIGFILE")
    USE_PHPPROTOCOL=$(jq -r .php_protocol "$CONFIGFILE")
    USE_PHPVERSION=$(jq -r .php_version "$CONFIGFILE")

    if [ "$THIS_PHPPROTOCOL" != "$USE_PHPPROTOCOL" ]; then
        continue;
    fi
    if [ "$THIS_PHPVERSION" != "" ] && [ "$THIS_PHPVERSION" != "$USE_PHPVERSION" ]; then
        continue;
    fi

    if [ -f "/data/shared/sites/$SITEBASENAME/.siteconfig/apache.conf" ]; then
        cp $d/.siteconfig/apache.conf /etc/apache2/sites-enabled/$SITEBASENAME.conf
        sed -i "s/^.*ServerName.*$/ServerName $SITEBASENAME.apache.$XCOMUSER.o.xotap.nl/gI" /etc/apache2/sites-enabled/$SITEBASENAME.conf
    else
        if [ ! -d "/data/shared/sites/$SITEBASENAME/htdocs" ]; then
            mkdir -p /data/shared/sites/$SITEBASENAME/htdocs
            chown web.web /data/shared/sites/$SITEBASENAME/htdocs
        fi
        if [ ! -d "/data/shared/sites/$SITEBASENAME/logs" ]; then
            mkdir -p /data/shared/sites/$SITEBASENAME/logs
        fi


        cat <<EOT > /etc/apache2/sites-enabled/$SITEBASENAME.conf
<VirtualHost *:##USE_PORT##>
    ServerName ##SITEBASENAME##.##XCOMUSER##.o.xotap.nl
    ServerAdmin webmaster@localhost
    DocumentRoot /data/shared/sites/##SITEBASENAME##/htdocs
    ErrorLog /data/shared/sites/##SITEBASENAME##/logs/error.apache.log
    CustomLog /data/shared/sites/##SITEBASENAME##/logs/access.apache.log combined
    <Directory /data/shared/sites/##SITEBASENAME##>
        ##PHP_VERSION_COMMENT##AddType application/x-httpd-fastphp##PHP_VERSION## .php

        SetEnv XCOM_SERVERTYPE dev
        SetEnv XCOM_SERVERUSER ##XCOMUSER##

        Options FollowSymLinks
        AllowOverride All
        Require all granted
        Satisfy Any
    </Directory>
</VirtualHost>

EOT
        cp /etc/apache2/sites-enabled/$SITEBASENAME.conf /data/shared/sites/$SITEBASENAME/.siteconfig/apache.conf.example

        if [ "$THIS_PHPVERSION" = "" ]; then
            sed -i "s/##PHP_VERSION_COMMENT##//g" /etc/apache2/sites-enabled/$SITEBASENAME.conf
        else
            sed -i "s/##PHP_VERSION_COMMENT##/#/g" /etc/apache2/sites-enabled/$SITEBASENAME.conf
        fi

        sed -i "s/##USE_PORT##/$USE_PORT/g" /etc/apache2/sites-enabled/$SITEBASENAME.conf
        sed -i "s/##PHP_VERSION##/$USE_PHPVERSION/g" /etc/apache2/sites-enabled/$SITEBASENAME.conf
        sed -i "s/##SITEBASENAME##/$SITEBASENAME/g" /etc/apache2/sites-enabled/$SITEBASENAME.conf
        sed -i "s/##XCOMUSER##/$XCOMUSER/g" /etc/apache2/sites-enabled/$SITEBASENAME.conf

        chown web.web /data/shared/sites/$SITEBASENAME/.siteconfig/apache.conf.example
    fi
done

sed -i "s/^Listen.*$/Listen $USE_PORT/g" /etc/apache2/ports.conf

if [ `ls -l /etc/apache2/sites-enabled | wc -l` -gt 1 ]; then
    /etc/init.d/nullmailer start
    /etc/init.d/apache2 start
    /etc/init.d/apache2 status
else
    tail -f /var/log/faillog
fi

if [ $? -eq 0 ];then
    tail -f /var/log/apache2/error.log
else
    exit $?
fi

