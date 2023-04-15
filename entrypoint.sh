#!/bin/sh

# Get the host UID and GID (prioritize HOST_USER_UID/GID, default to 1000 if not provided)
USER_UID=${HOST_USER_UID:-${HOST_UID:-1000}}
USER_GID=${HOST_USER_GID:-${HOST_GID:-1000}}

# Update the www-data user and group to match the host UID and GID
deluser www-data
addgroup -g $USER_GID -S www-data
adduser -u $USER_UID -D -S -G www-data www-data

# Enable or disable opcache based on HOST_ENV
if [ "$HOST_ENV" = "production" ]; then
    mv "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.disabled" "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
    ln -sf "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/conf.d/php.ini"
else
    mv "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.disabled"
    ln -sf "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/conf.d/php.ini"
fi

# Execute the passed command as www-data user
exec su-exec www-data "$@"
