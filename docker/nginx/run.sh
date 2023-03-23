#!/usr/bin/env bash

# configtest and restart
nginx -t

if service nginx restart; then
    tail -f /var/log/nginx/error.log
else
    tail -n 100 /var/log/nginx/error.log
    exit $?
fi
