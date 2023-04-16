#!/bin/sh

# Enable or disable opcache based on HOST_ENV
if [ "$HOST_ENV" = "production" ]; then
    mv "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.disabled" "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"
    ln -sf "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/conf.d/php.ini"
else
    mv "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.disabled"
    ln -sf "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/conf.d/php.ini"
fi

# Set the user for the `exec` command
USER_COMMAND="exec"
if [ -n "$HOST_USER_UID" ] && [ -n "$HOST_USER_GID" ]; then
    USER_COMMAND="su-exec www-data"
fi
if [ "$EXEC_AS_ROOT" = "true" ] || [ "$EXEC_AS_ROOT" = "1" ]; then
    USER_COMMAND="exec"
fi

# Execute the passed command with the correct user
$USER_COMMAND "$@"
