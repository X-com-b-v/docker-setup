#!/usr/bin/env bash

CONFIGFILE="$HOME/.config/docker-setup.config"
USERNAME=""
if [ -f "$CONFIGFILE" ]; then
    #shellcheck disable=SC1090
    . "$CONFIGFILE"
fi
if [ -z "$installdir" ]; then
    echo "installdir not found"
    exit 1
fi
if [ -z "$PROJECTSLUG" ]; then
    PROJECTSLUG=".o.xotap.nl"
fi

WEBPATH="/data/shared/sites"
DOMAIN=".${USERNAME}${PROJECTSLUG}"
WEBPATHESCAPED=$(echo $WEBPATH | sed 's/\//\\\//g')
PROXYPORT="8888"
NGINX_SITES_ENABLED="$(devctl dockerdir)"/nginx/sites-enabled
NGINX_SITE_TEMPLATES="$(devctl dockerdir)"/nginx/site-templates
APACHE_SITES_ENABLED="$(devctl dockerdir)"/apache/sites-enabled
APACHE_SITE_TEMPLATES="$(devctl dockerdir)"/apache/site-templates

# clear sites enabled
rm "$NGINX_SITES_ENABLED"/* "$APACHE_SITES_ENABLED"/* 2>/dev/null

createSiteConfigDir()  {
    if [ ! -d "$1"/.siteconfig ]; then
        mkdir -p "$1"/.siteconfig
    fi
}
createLogDir() {
    if [ ! -d "$1"/logs ]; then
        mkdir -p "$1"/logs
    fi
}
getFrameworkAndConfig() {
    FRAMEWORK=none
    CONFIG='{"template":"default","webserver":"nginx","php_version":"7.4"}'
    if [ -f "$1"/bin/magento ]; then
        FRAMEWORK=magento
        CONFIG='{"template":"magento2","webserver":"nginx","php_version":"7.4"}'
    elif [ -f "$1"/app/etc/local.xml ]; then
        FRAMEWORK=magento
        CONFIG='{"template":"magento","webserver":"nginx","php_version":"7.2"}'
    elif [ -d "$1"/htdocs/wire ]; then
        FRAMEWORK=processwire
        CONFIG='{"template":"default","webserver":"apache", "php_version":"7.4"}'
    fi
}
writeSampleConfig() {
    rm "$d"/.siteconfig/config.json.example 2>/dev/null
    echo "$1" > "$d"/.siteconfig/config.json.example
    CONFIGFILE="$d"/.siteconfig/config.json.example
}
handleParams () {
    rm "$2"/.siteconfig/params.conf.example 2>/dev/null
    cat << EOF > "$2/.siteconfig/params.conf.example"
fastcgi_param CONFIG__DEFAULT__WEB__UNSECURE__BASE_URL https://$1${DOMAIN}/;
fastcgi_param CONFIG__DEFAULT__WEB__SECURE__BASE_URL https://$1${DOMAIN}/;
fastcgi_param CONFIG__DEFAULT__WEB__UNSECURE__BASE_LINK_URL https://$1${DOMAIN}/;
fastcgi_param CONFIG__DEFAULT__WEB__SECURE__BASE_LINK_URL https://$1${DOMAIN}/;
fastcgi_param CONFIG__DEFAULT__WEB_COOKIE_COOKIE_DOMAIN $1${DOMAIN};
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__UNSECURE__BASE_URL https://$1.be${DOMAIN}/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__SECURE__BASE_URL https://$1.be${DOMAIN}/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__UNSECURE__BASE_LINK_URL https://$1.be${DOMAIN}/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB__SECURE__BASE_LINK_URL https://$1.be${DOMAIN}/;
fastcgi_param CONFIG__WEBSITES__MY_WEBSITE_CODE__WEB_COOKIE_COOKIE_DOMAIN $1.be${DOMAIN};
EOF
}
handleConfigs() {
    NGINXSAMPLEFILE="$d"/.siteconfig/nginx.conf.example
    NGINXCONFIGFILE="$NGINX_SITES_ENABLED"/"$SITEBASENAME".conf
    APACHESAMPLEFILE="$d"/.siteconfig/apache.conf.example
    APACHECONFIGFILE="$APACHE_SITES_ENABLED"/"$SITEBASENAME".conf
    # remove existing (sample) file because permissions and cleanup
    rm "$NGINXSAMPLEFILE" 2>/dev/null
    rm "$APACHESAMPLEFILE" 2>/dev/null
    handleNginxConfig
}
handleNginxConfig() {
    # https://stackoverflow.com/questions/18488651/how-to-break-out-of-a-loop-in-bash
    while : ; do
        # if webserver isnt nginx, always use the proxy configuration
        if [ "$USE_WEBSERVER" != "nginx" ] && [ "$SETUP_APACHE" == "on" ]; then
            cp "$NGINX_SITE_TEMPLATES"/proxy.conf "$NGINXCONFIGFILE"
            handleApacheConfig
            break
        fi
        # if nginx.conf is not example, always use this config
        if [ -f "$d"/.siteconfig/nginx.conf ]; then
            cp "$d"/.siteconfig/nginx.conf "$NGINXCONFIGFILE"
            break
        fi
        # check if an existing template is available
        if [ -f "$NGINX_SITE_TEMPLATES"/"$USE_TEMPLATE".conf ]; then
            cp "$NGINX_SITE_TEMPLATES"/"$USE_TEMPLATE".conf "$NGINXCONFIGFILE"
            break
        fi
        # if no existing template is available, resort to default
        if [ -f "$NGINX_SITE_TEMPLATES"/default.conf ]; then
            cp "$NGINX_SITE_TEMPLATES"/default.conf "$NGINXCONFIGFILE"
            break
        fi
        # nothing to do
        break
    done
    
    if [ -f "$NGINXCONFIGFILE" ]; then
        cp "$NGINXCONFIGFILE" "$NGINXSAMPLEFILE"
        replacePlaceholderValues "$NGINXCONFIGFILE"
    fi
}
handleApacheConfig() {
    # https://stackoverflow.com/questions/18488651/how-to-break-out-of-a-loop-in-bash
    while : ; do
        # if webserver isnt nginx, always use the proxy configuration
        if [ "$USE_WEBSERVER" == "apache" ]; then
            # if apache.conf is not example, always use this config
            if [ -f "$d"/.siteconfig/apache.conf ]; then
                cp "$d"/.siteconfig/apache.conf "$APACHECONFIGFILE"
                break
            fi
            # check if an existing template is available
            if [ -f "$APACHE_SITE_TEMPLATES"/"$USE_TEMPLATE".conf ]; then
                cp "$APACHE_SITE_TEMPLATES"/"$USE_TEMPLATE".conf "$APACHECONFIGFILE"
                break
            fi
            # fall back to default config 
            if [ -f "$APACHE_SITE_TEMPLATES"/default.conf ]; then
                cp "$APACHE_SITE_TEMPLATES"/default.conf "$APACHECONFIGFILE"
                break
            fi
        fi
        # do nothing
        break
    done
    if [ -f "$APACHECONFIGFILE" ]; then
        cp "$APACHECONFIGFILE" "$APACHESAMPLEFILE"
        replacePlaceholderValues "$APACHECONFIGFILE"
    fi
}
replacePlaceholderValues() {
    sed -i "s/##PROXYPORT##/$PROXYPORT/g" "$1"
    sed -i "s/##USE_PHPVERSION##/$USE_PHPVERSION/g" "$1"
    sed -i "s/##SITEBASENAME##/$SITEBASENAME/g" "$1"
    sed -i "s/##XCOMUSER##/$USERNAME/g" "$1"
    sed -i "s/##PROJECTSLUG##/$PROJECTSLUG/g" "$1"
    sed -i "s/##INCLUDE_PARAMS##/$INCLUDE_PARAMS/g" "$1"
    sed -i "s/##WEBPATH##/$WEBPATHESCAPED/g" "$1"
    sed -i "s/##DOMAIN##/$DOMAIN/g" "$1"
}

while IFS= read -r d
do
    SITEBASENAME=$(basename "$d")
    createSiteConfigDir "$d"
    createLogDir "$d"
    getFrameworkAndConfig "$d"
    INCLUDE_PARAMS=
    if [ "$FRAMEWORK" == "magento" ]; then
        handleParams "$SITEBASENAME" "$d"
        if [ -f "$d/.siteconfig/params.conf" ]; then
            INCLUDE_PARAMS="include $WEBPATHESCAPED\/$SITEBASENAME\/.siteconfig\/params.conf;"
        fi
    fi
    writeSampleConfig "$CONFIG"
    if [ -f "$d"/.siteconfig/config.json ]; then 
        CONFIGFILE="$d"/.siteconfig/config.json
    fi
    read -r USE_TEMPLATE USE_WEBSERVER USE_PHPVERSION <<< "$(jq -r '.template, .webserver, .php_version' "$CONFIGFILE" | xargs)"
    handleConfigs
done <   <(find -L "$installdir"/data/shared/sites -mindepth 1 -maxdepth 1 -type d)
