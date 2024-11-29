#!/usr/bin/env bash

# Exit on error, undefined vars, and propagate pipe failures
set -euo pipefail

# Ensure cleanup on script exit
cleanup() {
    if [ -n "${tmpfile:-}" ] && [ -f "$tmpfile" ]; then
        rm -f "$tmpfile"
    fi
}
trap cleanup EXIT

CONFIGFILE="$HOME/.config/docker-setup.config"
USERNAME=""

# Source config file if it exists
if [ -f "$CONFIGFILE" ]; then
    #shellcheck disable=SC1090
    if ! . "$CONFIGFILE"; then
        echo "Error: Failed to source config file: $CONFIGFILE" >&2
        exit 1
    fi
fi

# Validate required variables
if [ -z "${installdir:-}" ]; then
    echo "Error: installdir not found in config" >&2
    exit 1
fi

# Set default project slug if not defined
PROJECTSLUG="${PROJECTSLUG:-.o.xotap.nl}"

WEBPATH="/data/shared/sites"
DOMAIN=".${USERNAME}${PROJECTSLUG}"

# Handle path escaping based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    WEBPATHESCAPED=$(echo "$WEBPATH" | sed -e 's/\//\\\//g')
else
    WEBPATHESCAPED=$(echo "$WEBPATH" | sed 's/\//\\\//g')
fi

PROXYPORT="8888"
NGINX_SITES_ENABLED="$(devctl dockerdir)"/nginx/sites-enabled
NGINX_SITE_TEMPLATES="$(devctl dockerdir)"/nginx/site-templates
APACHE_SITES_ENABLED="$(devctl dockerdir)"/apache/sites-enabled
APACHE_SITE_TEMPLATES="$(devctl dockerdir)"/apache/site-templates

# Clear sites enabled (suppress errors if directories are empty)
rm -f "$NGINX_SITES_ENABLED"/* "$APACHE_SITES_ENABLED"/* 2>/dev/null || true

createSiteConfigDir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Error: Base directory does not exist: $dir" >&2
        return 1
    fi
    if [ ! -d "$dir"/.siteconfig ]; then
        if ! mkdir -p "$dir"/.siteconfig; then
            echo "Error: Failed to create .siteconfig directory in $dir" >&2
            return 1
        fi
    fi
}

createLogDir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Error: Base directory does not exist: $dir" >&2
        return 1
    fi
    if [ ! -d "$dir"/logs ]; then
        if ! mkdir -p "$dir"/logs; then
            echo "Error: Failed to create logs directory in $dir" >&2
            return 1
        fi
    fi
}

getFrameworkAndConfig() {
    local dir="$1"
    FRAMEWORK=none
    CONFIG='{"template":"default","webserver":"nginx","php_version":"latest"}'
    
    if [ ! -d "$dir" ]; then
        echo "Error: Directory does not exist: $dir" >&2
        return 1
    fi
    
    if [ -f "$dir"/bin/magento ]; then
        FRAMEWORK=magento
        CONFIG='{"template":"magento2","webserver":"nginx","php_version":"latest"}'
    elif [ -f "$dir"/app/etc/local.xml ]; then
        FRAMEWORK=magento
        CONFIG='{"template":"magento","webserver":"nginx","php_version":"7.4"}'
    elif [ -d "$dir"/web ]; then
        FRAMEWORK=craft
        CONFIG='{"template":"craft","webserver":"nginx", "php_version":"latest"}'
    elif [ -d "$dir"/htdocs/wire ]; then
        FRAMEWORK=processwire
        CONFIG='{"template":"processwire","webserver":"apache", "php_version":"latest"}'
    elif [ -d "$dir"/htdocs ]; then
            FRAMEWORK=none
            CONFIG='{"template":"default","webserver":"apache", "php_version":"latest"}'
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

    if [ "$USE_PHPVERSION" == "latest" ]; then
        USE_PHPVERSION="$PHPLATEST" # PHPLATEST is written to config file
    fi
    handleNginxConfig
}
handleNginxConfig() {
    # https://stackoverflow.com/questions/18488651/how-to-break-out-of-a-loop-in-bash
    while : ; do
        unset SKIPSAMPLE
        # if nginx.conf is not example, always use this config
        if [ -f "$d"/.siteconfig/nginx.conf ]; then
            cp "$d"/.siteconfig/nginx.conf "$NGINXCONFIGFILE"
            if [ "$USE_WEBSERVER" != "nginx" ] && [ "$SETUP_APACHE" == "on" ]; then
                cp "$NGINX_SITE_TEMPLATES"/proxy.conf "$NGINXSAMPLEFILE"
                handleApacheConfig
                SKIPSAMPLE=1
            fi
            break
        fi
        # if webserver isnt nginx, always use the proxy configuration
        if [ "$USE_WEBSERVER" != "nginx" ] && [ "$SETUP_APACHE" == "on" ]; then
            cp "$NGINX_SITE_TEMPLATES"/proxy.conf "$NGINXCONFIGFILE"
            handleApacheConfig
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
        if [ -z "$SKIPSAMPLE" ]; then
            cp "$NGINXCONFIGFILE" "$NGINXSAMPLEFILE"
        fi
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
    local file="$1"
    local sedcmd
    
    # Validate input file exists
    if [ ! -f "$file" ]; then
        echo "Error: File does not exist: $file" >&2
        return 1
    fi
    
    # Validate required variables
    local required_vars=(PROXYPORT USE_PHPVERSION SITEBASENAME USERNAME PROJECTSLUG INCLUDE_PARAMS WEBPATHESCAPED DOMAIN)
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            echo "Error: Required variable not set: $var" >&2
            return 1
        fi
    done
    
    # Determine sed command based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS requires empty string argument for -i
        sedcmd="sed -i ''"
    else
        # Linux version
        sedcmd="sed -i"
    fi
    
    # Apply all replacements using the appropriate sed command
    local replacements=(
        "s/##PROXYPORT##/$PROXYPORT/g"
        "s/##USE_PHPVERSION##/$USE_PHPVERSION/g"
        "s/##SITEBASENAME##/$SITEBASENAME/g"
        "s/##XCOMUSER##/$USERNAME/g"
        "s/##PROJECTSLUG##/$PROJECTSLUG/g"
        "s/##INCLUDE_PARAMS##/$INCLUDE_PARAMS/g"
        "s/##WEBPATH##/$WEBPATHESCAPED/g"
        "s/##DOMAIN##/$DOMAIN/g"
    )
    
    for replacement in "${replacements[@]}"; do
        if ! $sedcmd "$replacement" "$file"; then
            echo "Error: Failed to apply replacement: $replacement" >&2
            return 1
        fi
    done
}

# Create a temporary file to store the output of the find command
tmpfile=$(mktemp)
find -L "$installdir"/data/shared/sites -mindepth 1 -maxdepth 1 -type d > "$tmpfile"

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
    if [ "$FRAMEWORK" == "craft" ]; then
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
done < "$tmpfile"

# Remove the temporary file
rm "$tmpfile"
