#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "No arguments provided"
    docker ps --format '{{.Names}}'
    exit 1
fi

# do not edit $FALLBACK
FALLBACK="sh"
SHELL="bash";
PREPEND=

# check if current user is not in group docker
if ! groups "$USER" | grep &>/dev/null '\bdocker\b'; then
    PREPEND="sudo"
fi

EXITCODE=0
cd "$(devctl dockerdir)" || echo "Dockerdir not found"
# check if $SHELL exists on target, only when configured $SHELL is different from $FALLBACK
if [[ "$SHELL" != "$FALLBACK" ]]; then
    ${PREPEND} docker compose exec "$@" which $SHELL > /dev/null 2>&1
fi

EXITCODE=$?
# check if latest command exit code is not 0
if [ ! "$EXITCODE" = "0" ]; then
    ${PREPEND} docker compose exec "$@" $FALLBACK
else
    ${PREPEND} docker compose exec "$@" $SHELL
fi
