# for m1 macs running php-fpm images, as iUS/Remi repos do not have RPMs 

docker-compose.yml
```yaml
  php74:
    platform: linux/arm64/v8
    image: madebymode/php74-arm64-alpine
    build: github.com/madebymode/docker-arm64-php74.git
    ports:
      - "9000:9000"
    volumes:
      # real time sync for app php files
      - .:/app
      # cache laravel libraries dir
      - ./vendor:/app/vendor:cached
      # logs and sessions should be authorative inside docker
      - ./storage:/app/storage:delegated
      # cache static assets bc fpm doesn't need to update css or js
      - ./public:/app/public:cached
      # additional php config
      - ./docker-conf/php-ini:/usr/local/etc/php/custom.d
    env_file:
      - .env
    environment:
      - PHP_INI_SCAN_DIR=/usr/local/etc/php/custom.d:/usr/local/etc/php/conf.d/
      - COMPOSER_AUTH=${COMPOSER_AUTH}
```
