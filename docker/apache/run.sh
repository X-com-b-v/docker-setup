#!/usr/bin/env bash

#DOMAIN=`jq -r .domain /opt/devserver/config.json`
#DEFAULT_PHP=`jq -r .default_php /opt/devserver/config.json`
#WEBPATH=`jq -r .sitesroot /opt/devserver/config.json`
#WEBPATHESCAPED=$(jq -r .sitesroot /opt/devserver/config.json | sed 's/\//\\\//g')

CONFIGFILE="/etc/docker-setup.config"
USERNAME=""
if [ -f "$CONFIGFILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIGFILE"
fi

if [ -z "$USERNAME" ]; then
    echo 'Username not set, cannot continue creating hosts'
    exit 1
fi

if [ -z "$PROJECTSLUG" ]; then
    PROJECTSLUG=".o.xotap.nl"
fi

WEBPATH="/data/shared/sites"
DOMAIN=".${USERNAME}${PROJECTSLUG}"
DEFAULT_PHP="7.4"
WEBPATHESCAPED=$(echo "$WEBPATH" | sed 's/\//\\\//g')

createSiteConfigDir()  {
    if [ ! -d "$1"/.siteconfig ]; then
        mkdir -p "$1"/.siteconfig
        chown -R web.web "$1"/.siteconfig
    fi
}

rm /etc/apache2/sites-enabled/*
while IFS= read -r d
do
    SITEBASENAME=$(basename "$d")
    CONFIGFILE="$WEBPATH/$SITEBASENAME/.siteconfig/config.json.example"

    # check if logging dir exists
    if [ ! -d "/data/shared/sites/$SITEBASENAME/logs"  ]; then
        mkdir -p /data/shared/sites/"$SITEBASENAME"/logs
        chown -R web.web /data/shared/sites/"$SITEBASENAME"/logs
    fi

    if [ -f "$WEBPATH/$SITEBASENAME/.siteconfig/config.json" ]; then
        CONFIGFILE="$WEBPATH/$SITEBASENAME/.siteconfig/config.json"
    elif [ -f "$WEBPATH/$SITEBASENAME/config/pre_index.php" ]; then
        # itix hosting
        createSiteConfigDir "$WEBPATH/$SITEBASENAME";
        echo '{"template":"default","webserver":"apache","php_version":"7.2"}' > "$WEBPATH/$SITEBASENAME/.siteconfig/config.json.example"
    elif [ -d "$WEBPATH/$SITEBASENAME/htdocs" ] && [ ! -d "$WEBPATH/$SITEBASENAME/htdocs/wire" ] ; then
        # default hosting
        createSiteConfigDir "$WEBPATH/$SITEBASENAME";
        echo '{"template":"default","webserver":"apache","php_version":"default"}' > "$WEBPATH/$SITEBASENAME/.siteconfig/config.json.example"
    elif [ -d "$WEBPATH/$SITEBASENAME/htdocs/updateinfo" ]; then
        # Lijkt itix
        createSiteConfigDir "$WEBPATH/$SITEBASENAME";
        echo '{"template":"default","webserver":"apache","php_protocol":"mod_php","php_version":"latest"}' > "$WEBPATH/$SITEBASENAME/.siteconfig/config.json.example"
    else
        # no site
        continue;
    fi


    PROXYPORT="8888"
    USE_WEBSERVER=$(jq -r .webserver "$CONFIGFILE")
    USE_PHPVERSION=$(jq -r .php_version "$CONFIGFILE")

    if [ "$USE_PHPVERSION" = "default" ]; then
      USE_PHPVERSION="$DEFAULT_PHP"
    fi

    if ! [[ $USE_PHPVERSION =~ ^([0-9]+\.[0-9]+)$ ]]; then
      USE_PHPVERSION="$DEFAULT_PHP"
    fi
    
    if [ "$USE_WEBSERVER" != "nginx" ]; then
        # Nginx is not needed, just forward traffic to next webserver
        # only create vhosts for apache when it is actually necessary
        if [ "$USE_WEBSERVER" = "apache" ]; then
            cp /etc/apache/site-templates/default.conf "$WEBPATH"/"$SITEBASENAME"/.siteconfig/apache.conf.example
            cp /etc/apache/site-templates/default.conf /etc/apache2/sites-enabled/"$SITEBASENAME".conf

            sed -i "s/##PROXYPORT##/$PROXYPORT/g" /etc/apache2/sites-enabled/"$SITEBASENAME".conf 2> /dev/null
            sed -i "s/##USE_PHPVERSION##/$USE_PHPVERSION/g" /etc/apache2/sites-enabled/"$SITEBASENAME".conf 2> /dev/null
            sed -i "s/##SITEBASENAME##/$SITEBASENAME/g" /etc/apache2/sites-enabled/"$SITEBASENAME".conf 2> /dev/null
            sed -i "s/##DOMAIN##/$DOMAIN/g" /etc/apache2/sites-enabled/"$SITEBASENAME".conf 2> /dev/null
            sed -i "s/##INCLUDE_PARAMS##/$INCLUDE_PARAMS/g" /etc/apache2/sites-enabled/"$SITEBASENAME".conf 2> /dev/null
            sed -i "s/##WEBPATH##/$WEBPATHESCAPED/g" /etc/apache2/sites-enabled/"$SITEBASENAME".conf 2> /dev/null
            sed -i "s/##XCOMUSER##/$USERNAME/g" /etc/apache2/sites-enabled/"$SITEBASENAME".conf 2> /dev/null
        fi  
    fi
done <   <(find -L "$WEBPATH" -mindepth 1 -maxdepth 1 -type d)

service apache2 restart

if service apache2 restart; then
    tail -f /var/log/apache2/error.log
else
    tail -n 100 /var/log/apache2/error.log
    exit $?
fi
