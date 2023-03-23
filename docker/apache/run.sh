#!/usr/bin/env bash

apachectl -t

if service apache2 restart; then
    tail -f /var/log/apache2/error.log
else
    tail -n 100 /var/log/apache2/error.log
    exit $?
fi
