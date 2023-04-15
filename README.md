# cross platform alpine-based php74 image



### build instructions

 make sure these ENV varaiables exist on your host-machine

```
HOST_USER_GID
HOST_USER_UID
```
#### set these env vars

ie on `macOS` in `~/.extra` or `~/.bash_profile`

get `HOST_USER_UID`

```
id -u
```


get `HOST_USER_GID`
```
id -g
```


### run
```
echo "export HOST_USER_GID=$(id -g)" >> ~/.bash_profile && echo "export HOST_USER_UID=$(id -u)" >> ~/.bash_profile && echo "export DOCKER_USER=$(id -u):$(id -g)" >> ~/.bash_profile
```



docker-compose.yml
```yaml
  php74:
    platform: linux/arm64/v8
    image: madebymode/php74-arm64-alpine
    build: github.com/madebymode/docker-arm64-php74.git
    # optional: not needed if you're running macOS
    user: '${HOST_USER_UID:-1000}:${HOST_USER_GID:-1000}' # Uses the host's environment variables if they exist, otherwise uses the default values 1000:1000
    # optional: disable if you're running behind a proxy like traefik
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
      # additional php config REQUIRED
      - ./docker-conf/php-ini:/usr/local/etc/php/custom.d
    env_file:
      - .env
    environment:
      # note that apline has dif dir structures: /user/local/etc - conf.d need to be scanned here for all modules from image
      - PHP_INI_SCAN_DIR=/usr/local/etc/php/custom.d:/usr/local/etc/php/conf.d/
      - COMPOSER_AUTH=${COMPOSER_AUTH}
      # optional: if you wanna run as root
      - COMPOSER_ALLOW_SUPERUSER=1
```
