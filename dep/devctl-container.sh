#!/usr/bin/env bash
# Container-side devctl — subset of host devctl for use inside PHP containers.
# Requires Docker socket mounted at /var/run/docker.sock.

case "$1" in
    reload)
        NGINX=$(docker ps -qf "name=nginx" --filter "status=running" | head -1)
        [ -z "$NGINX" ] && echo "nginx container not found" && exit 1
        docker exec "$NGINX" nginx -s reload && echo "nginx reloaded"
        ;;
    flushredis)
        REDIS=$(docker ps -qf "name=redis" --filter "status=running" | head -1)
        [ -z "$REDIS" ] && echo "redis container not found" && exit 1
        if [ -n "$2" ]; then
            docker exec "$REDIS" redis-cli -n "$2" flushdb
        else
            docker exec "$REDIS" redis-cli flushall
        fi
        ;;
    restart)
        [ -z "$2" ] && echo "Usage: devctl restart <container>" && exit 1
        docker restart "$2"
        ;;
    ps|status)
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    tail)
        [ -z "$2" ] && echo "Usage: devctl tail <container>" && exit 1
        docker logs -f "$2"
        ;;
    *)
        echo "Container devctl — available commands:"
        echo "  reload              Reload nginx (picks up config changes)"
        echo "  flushredis [db]     Flush Redis cache"
        echo "  restart <container> Restart a container"
        echo "  tail <container>    Follow container logs"
        echo "  ps / status         Show running containers"
        ;;
esac
