#!/bin/sh

if [ "$APP_ENV" = "production" ]; then
    cp /tmp/opcache-production.ini $PHP_INI_DIR/conf.d/opcache.ini
fi
