FROM php:7.4-fpm-alpine3.16

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/community" >> /etc/apk/repositories

# Add Build Dependencies
RUN apk add --no-cache --virtual .build-deps \
    zlib-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    bzip2-dev \
    zip \
    libwebp-dev \
    openssl-dev

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
    gcompat \
    icu-dev \
    freetype-dev \
    libzip-dev \
    bzip2 \
    libwebp \
    libpng \
    fcgi

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
    soap \
    phar \
    opcache && \
    apk del -f .build-deps

LABEL afterapk="php-fpm-alpine-$PHP_VERSION"

ARG HOST_ENV=development

# Create and configure status.conf for PHP-FPM status page
RUN echo '[www]' > /usr/local/etc/php-fpm.d/status.conf && \
    echo 'pm.status_path = /status' >> /usr/local/etc/php-fpm.d/status.conf

# Health check script
COPY ./php-fpm-healthcheck /usr/local/bin/
RUN chmod +x /usr/local/bin/php-fpm-healthcheck

# Install Composer 1.10
RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.22 --install-dir=/usr/local/bin --filename=composer
# Install Composer 2
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer2
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"

# Setup Working Dir
WORKDIR /app

# Add Healthcheck
HEALTHCHECK --interval=5s --timeout=1s \
    CMD php-fpm-healthcheck || exit 1

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint

# Set permissions for the entrypoint script
RUN chmod +x /usr/local/bin/entrypoint

# Set entrypoint
ENTRYPOINT ["entrypoint"]

# Set default command
CMD ["php-fpm", "-F"]
