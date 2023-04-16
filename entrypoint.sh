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
    cp -f "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" "$PHP_INI_DIR/conf.d/"
    ln -sf "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
else
    rm -f "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
    ln -sf "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
fi

# Check if EXEC_AS_ROOT is set to 1 and switch to root user if true
if [ "$EXEC_AS_ROOT" = "1" ]; then
  exec "$@"
else
  # Switch to the www-data user
  su -s /bin/sh -c 'exec "$0" "$@"' www-data -- "$@"
fi
