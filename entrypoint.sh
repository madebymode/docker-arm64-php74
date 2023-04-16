#!/bin/sh

# Enable or disable opcache based on HOST_ENV
if [ "$HOST_ENV" = "production" ]; then
    cp -f "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" "$PHP_INI_DIR/conf.d/"
    ln -sf "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
else
    rm -f "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
    ln -sf "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
fi

exec "$@"
