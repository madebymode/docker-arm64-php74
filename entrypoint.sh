#!/bin/sh

# Enable or disable opcache based on HOST_ENV
if [ "$HOST_ENV" = "production" ]; then
    mv "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.disabled" "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
    ln -sf "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/conf.d/php.ini"
else
    mv "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.disabled"
    ln -sf "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/conf.d/php.ini"
fi

# Execute the passed command
exec "$@"
