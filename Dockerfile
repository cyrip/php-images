FROM php:8.3-cli-bullseye

RUN sed -i 's/deb\.debian\.org/ftp.de.debian.org/g' /etc/apt/sources.list

RUN apt-get update --fix-missing && \
#    apt-get install --yes nmap curl iputils-ping psutils net-tools bind9-host bind9utils telnet && \
    apt-get install --yes libssl-dev libcurl4-openssl-dev libc-ares-dev libssl-dev libcurl4-openssl-dev libxml2-dev libzip-dev liblz4-dev libzstd-dev libpng-dev tini && \
    apt-get clean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN docker-php-ext-configure bcmath && docker-php-ext-configure gd && docker-php-ext-configure pdo_mysql && docker-php-ext-configure calendar && docker-php-ext-configure zip && \
    docker-php-ext-install bcmath pdo_mysql calendar zip gd && \
#    docker-php-ext-enable bcmath pdo_mysql calendar zip gd && \
    printf "no\nyes\nyes\nno\nyes\yes" | pecl install redis && \
    docker-php-ext-enable redis

RUN docker-php-ext-configure sockets && docker-php-ext-install --ini-name 01-sockets.ini sockets && \
    docker-php-ext-configure pcntl --enable-pcntl && docker-php-ext-install --ini-name 01-pcntl.ini pcntl && \
    docker-php-ext-configure soap && docker-php-ext-install --ini-name 01-soap.ini soap

RUN printf "yes\nyes\nyes\nyes\nyes\nno\n" | pecl install -f openswoole
RUN docker-php-ext-enable --ini-name 02-openswoole.ini openswoole && \
    rm -rf /tmp/pear && \
    docker-php-source delete

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -i 's/^memory_limit.*/memory_limit = 1024M/g' /usr/local/etc/php/php.ini

EXPOSE 8000
WORKDIR /app
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD php artisan octane:start --host 0.0.0.0 --port 8000
