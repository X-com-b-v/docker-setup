#!/usr/bin/env bash

echo "Validating Apache configuration..."
if apachectl -t; then
    echo "Configuration is valid."
else
    echo "Apache configuration is invalid!"
    exit 1
fi

echo "Restarting Apache service..."
if service apache2 restart; then
    echo "Apache restarted successfully. Following error log:"
    tail -f /var/log/apache2/error.log
else
    echo "Failed to restart Apache! Showing last 100 error log entries:"
    tail -n 100 /var/log/apache2/error.log
    exit $?
fi
