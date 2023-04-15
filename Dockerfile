FROM php:7.4-fpm-alpine3.15

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories

# Add Build Dependencies
RUN apk add --no-cache --virtual .build-deps \
    zlib-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    bzip2-dev \
    zip \
    libwebp-dev \
    icu-dev \
    freetype-dev \
    libzip-dev

# Add App Dependencies
RUN apk add --update --no-cache \
    jpegoptim \
    pngquant \
    optipng \
    vim \
    mysql-client \
    bash \
    shared-mime-info \
    git \
    curl \
    wget \
    gcompat

# Configure & Install Extension
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/ --with-webp=/usr/include/ && \
    docker-php-ext-install \
    mysqli \
    pdo \
    pdo_mysql \
    sockets \
    json \
    intl \
    gd \
    xml \
    bz2 \
    pcntl \
    bcmath \
    zip \
    fileinfo \
    soap && \
    apk del -f .build-deps

RUN ln -sf "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/conf.d/php.ini"

# Install Composer 1.10
RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.22 --install-dir=/usr/local/bin --filename=composer
# Install Composer 2
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer2
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"

# Create and configure status.conf for PHP-FPM status page
RUN echo '[www]' > /usr/local/etc/php-fpm.d/status.conf && \
    echo 'pm.status_path = /status' >> /usr/local/etc/php-fpm.d/status.conf


# Setup Working Dir
WORKDIR /app

# Add Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD SCRIPT_NAME=/status SCRIPT_FILENAME=/status QUERY_STRING= REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

