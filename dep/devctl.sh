#!/usr/bin/env bash

# Exit on error, undefined vars, and propagate pipe failures
set -euo pipefail

usage () {
cat <<EOF
Devenv version: $(get_installversion)
Usage: $0 [options]
All commands are executed in context of installdirectory/docker
Options:
                        | Show this help
up [containers]         | Create and daemonize containers. Start existing containers
restart [containers]    | Restart containers
stop [containers]       | Stop containers
start                   | Start all built containers
status|ps               | Shows running status of all containers managed by this docker-compose file (ps -a)
build [containers]      | Build images in docker-compose file
pull [containers]       | Pull images in docker-compose file
installdir              | Shows current install directory
dockerdir               | Shows current docker directory
varnishacl              | Update the varnish vcl with docker_xcom_network ip/subnet
flushredis [db]         | Flush redis completely, or a single db
flushvarnish [url]      | Flush varnish url
tail [container]        | Tail container logs
updatehosts             | Update hostfile
reload                  | Updates hostfile and reloads nginx [optionally apache]
recreate [containers]   | Force recreate containers. Useful after enabling/disabling Xdebug
EOF
}

get_installdir() {
    # Source config file to get installdir
    if [ -f "$HOME/.config/docker-setup.config" ]; then
        # shellcheck disable=SC1090
        . "$HOME/.config/docker-setup.config"
    fi
    
    if [ -z "${installdir:-}" ]; then
        echo "Error: installdir not found in config" >&2
        exit 1
    fi
    
    echo "$installdir"
}

get_dockerdir() {
    echo "$(get_installdir)/docker"
}

flush_redis () {
    cd "$(get_dockerdir)" || return
    if [ $# -eq 0 ]; then
        docker compose exec redis redis-cli flushall
        return
    fi
    docker compose exec redis redis-cli -n "$1" flushdb
}

flush_varnish () {
    curl -X PURGE -H "X-Magento-Tags-Pattern: .*" -k "$1"
}

update_varnish_acl () {
    # fetch subnet from docker xcom network
    SUBNET=$(docker network inspect x-com_xcom_network | jq '.[].IPAM.Config[].Subnet')
    if [ -n "$SUBNET" ]; then
        echo "$SUBNET"
        cd "$(get_dockerdir)" || return
        sed -i -e 's:"172.18.0.0/16":'"$SUBNET"':g' varnish/default.vcl
    fi
}

get_configfile () {
    CONFIGFILE="$HOME/.config/docker-setup.config"
    if [ -f "$CONFIGFILE" ]; then
        # shellcheck disable=SC1090
        . "$CONFIGFILE"
    fi
}

get_installversion () {
    get_configfile
    if [ -n "$VERSION" ]; then
        echo "$VERSION"
    fi   
}

update_hosts () {
    INSTALLDIR=$(get_installdir)
    HOSTS="/etc/hosts"
    IPADDR=127.0.0.1
    # check if wsl
    if [ -d '/mnt/c' ]; then
        HOSTS="/mnt/c/Windows/System32/drivers/etc/hosts"
        IPADDR=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    fi
    
    # Get config values
    get_configfile
    if [ -z "${USERNAME:-}" ] || [ -z "${PROJECTSLUG:-}" ]; then
        echo "Error: USERNAME or PROJECTSLUG not found in config" >&2
        exit 1
    fi
    
    # Create temporary file with proper permissions
    TMPHOSTS=$(mktemp)
    trap 'rm -f "$TMPHOSTS"' EXIT
    
    # Copy original hosts file with proper permissions
    if ! sudo cp "$HOSTS" "$TMPHOSTS"; then
        echo "Error: Failed to copy hosts file" >&2
        exit 1
    fi
    sudo chown "$(id -u):$(id -g)" "$TMPHOSTS"
    chmod 644 "$TMPHOSTS"
    
    # Remove existing XCOM entries
    sed -i.bak '/^#START XCOM HOSTS$/,/^#END XCOM HOSTS$/d' "$TMPHOSTS"
    
    # Add new XCOM entries
    {
        echo "#START XCOM HOSTS"
        # Check if sites directory exists
        SITES_DIR="$INSTALLDIR/data/shared/sites"
        if [ -d "$SITES_DIR" ]; then
            while IFS= read -r d; do
                if [ -d "$d" ]; then
                    SITEBASENAME=$(basename "$d")
                    echo "$IPADDR" "$SITEBASENAME.$USERNAME$PROJECTSLUG"
                fi
            done < <(find -L "$SITES_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
        fi
        echo "$IPADDR devserver"
        echo "#END XCOM HOSTS"
    } >> "$TMPHOSTS"
    
    # Verify and update the hosts file
    if ! sudo cp "$TMPHOSTS" "$HOSTS"; then
        echo "Error: Failed to update hosts file" >&2
        exit 1
    fi
    
    echo "Successfully updated hosts file"
}

# Process commands
case "$1" in
    up|restart|stop|start|status|ps|build|pull|recreate)
        # Change to docker directory for docker-compose commands
        cd "$(get_installdir)"/docker || exit 1
        case "$1" in
            up)
                docker compose up -d "${@:2}"
                update_hosts
                ;;
            restart)
                docker compose restart "${@:2}"
                ;;
            stop)
                docker compose stop "${@:2}"
                ;;
            start)
                docker compose start "${@:2}"
                ;;
            status|ps)
                docker compose ps -a
                ;;
            build)
                docker compose build "${@:2}"
                ;;
            pull)
                docker compose pull "${@:2}"
                ;;
            recreate)
                docker compose up -d --force-recreate "${@:2}"
                ;;
        esac
        ;;
    installdir)
        get_installdir
        ;;
    dockerdir)
        get_dockerdir
        ;;
    varnishacl)
        update_varnish_acl
        ;;
    flushredis)
        flush_redis "${2:-}"
        ;;
    flushvarnish)
        flush_varnish "${2:-}"
        ;;
    tail)
        cd "$(get_installdir)"/docker || exit 1
        docker compose logs -f "${2:-}"
        ;;
    updatehosts)
        update_hosts
        ;;
    reload)
        update_hosts
        cd "$(get_dockerdir)" || exit 1
        nginx-sites
        if ! docker compose exec nginx nginx -t; then
            echo "Error: Nginx configuration test failed" >&2
            exit 1
        fi
        # Use PID file for more reliable nginx reload
        if ! docker compose exec nginx /bin/sh -c 'if [ -f /var/run/nginx.pid ]; then kill -HUP $(cat /var/run/nginx.pid); else echo "Error: Nginx PID file not found" >&2; exit 1; fi'; then
            echo "Error: Failed to reload Nginx" >&2
            exit 1
        fi
        if [ "${SETUP_APACHE:-}" = "on" ]; then
            if ! docker compose exec apache apachectl -t; then
                echo "Error: Apache configuration test failed" >&2
                exit 1
            fi
            if ! docker compose exec apache service apache2 reload; then
                echo "Error: Failed to reload Apache" >&2
                exit 1
            fi
        fi
        ;;
    version)
        get_installversion
        ;;
    *)
        usage
        exit 1
esac
exit 0
