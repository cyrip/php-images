FROM php:8.3-cli-alpine

RUN apk update && apk add --no-cache --virtual .build-deps \
        autoconf \
        g++ \
        make \
    && apk --no-cache add \
        openssl-dev \
        curl-dev \
        c-ares-dev \
        libxml2-dev \
        libzip-dev \
        lz4-dev \
        zstd-dev \
        libpng-dev \
        linux-headers \
	tini \
    && docker-php-ext-install bcmath pdo_mysql calendar zip sockets pcntl soap gd \
    && docker-php-ext-enable bcmath pdo_mysql calendar zip sockets pcntl soap gd \
    && printf "no\nyes\nyes\nno\nyes\yes" | pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install -f openswoole \
    && docker-php-ext-enable openswoole \
    && apk del .build-deps \
    && rm -rf /tmp/* /var/cache/apk/*

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i 's/^memory_limit.*/memory_limit = 1024M/g' /usr/local/etc/php/php.ini

EXPOSE 8000
WORKDIR /app
ENTRYPOINT ["/sbin/tini", "--"]
CMD php artisan octane:start --host 0.0.0.0 --port 8000