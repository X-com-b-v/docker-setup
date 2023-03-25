#!/usr/bin/env bash

usage () {
cat <<EOF
Devenv version: $(get_installversion)
Usage: $0 [options]
All commands are executed in context of installdirectory/docker
Options:
                        | Show this help
up [containers]         | Create and daemonize containers. Start existing containers
restart [containers]    | Restart containers
stop [containers]       | Stop containers.
start                   | Start all built containers
status|ps               | Shows running status of all containers managed by this docker-compose file (ps -a)
build [containers]      | Build containers in docker-compose file
installdir              | Shows current install directory
dockerdir               | Shows current docker directory
sonarqube [options]     | Manage sonarqube and postgres instances
varnishacl              | Update the varnish vcl with docker_xcom_network ip/subnet
flushredis [db]         | Flush redis completely, or a single db
flushvarnish [url]      | Flush varnish url
tail [container]        | Tail container logs
updatehosts             | Update hostfile
reload                  | Updates hostfile and reloads nginx [optionally apache]
EOF
}

get_installdir() {
    echo "installdirectory"
}
get_dockerdir() {
    echo "installdirectory/docker"
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
    SUBNET=$(docker network inspect docker_xcom_network | jq '.[].IPAM.Config[].Subnet')
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
    CONFIGFILE="$HOME/.config/docker-setup.config"
    USERNAME=""
    get_configfile
    TMPHOSTS="/tmp/hosts"
    if [ ! -f $TMPHOSTS ]; then
        touch $TMPHOSTS
    fi
    sudo chmod 755 $TMPHOSTS
    cp $HOSTS $TMPHOSTS
    sed -i '/#START XCOM HOSTS/,/#END XCOM HOSTS/d' $TMPHOSTS
    echo "#START XCOM HOSTS" >> $TMPHOSTS
    while IFS= read -r d
    do
        SITEBASENAME=$(basename "$d")
        echo "$IPADDR" "$SITEBASENAME"."$USERNAME""$PROJECTSLUG" >> "$TMPHOSTS"
    done <   <(find -L "$INSTALLDIR"/data/shared/sites -mindepth 1 -maxdepth 1 -type d)

    echo "$IPADDR" "devserver" >> "$TMPHOSTS"
    echo "#END XCOM HOSTS" >> "$TMPHOSTS"
    sudo cp "$TMPHOSTS" "$HOSTS"
    rm "$TMPHOSTS"
}

cd installdirectory/docker || return
case "$1" in
    up)
        docker compose up -d "${@:2}"
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
        docker compose build --no-cache "${@:2}"
        ;;
    installdir)
        get_installdir
        ;;
    dockerdir)
        get_dockerdir
        ;;
    sonarqube)
        docker compose -f sonarqube.yml "${@:2}"
	    ;;
    varnishacl)
        update_varnish_acl
        ;;
    flushredis)
        flush_redis "$2"
        ;;
    flushvarnish)
        flush_varnish "$2"
        ;;
    tail)
        docker compose logs -f "$2"
        ;;
    updatehosts)
        update_hosts
        ;;
    reload)
        update_hosts
        get_configfile
        cd "$(get_dockerdir)" || return
        nginx-sites
        if docker compose exec nginx nginx -t; then
            docker compose exec nginx service nginx reload
        fi
        if [ "$SETUP_APACHE" == "on" ]; then
            if docker compose exec apache apachectl -t; then
                docker compose exec apache service apache2 reload
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
