FROM php:8.2-cli-alpine

# Update package list
RUN apk update
RUN apk upgrade -q -U -a

RUN apk update && apk add --no-cache bash

RUN curl -s https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer self-update

# install opcache, for a 20%+ performance boost!
RUN apk add --no-cache --update \
    --virtual .build-deps linux-headers $PHPIZE_DEPS \
    && docker-php-ext-install opcache \
    && docker-php-ext-enable opcache \
    && apk del .build-deps \
    && rm -rf /tmp/pear \
    && rm -rf /var/cache/apk/*

# install pcov, which is used for running phpunit with coverage, faster
RUN apk add --no-cache --update \
    --virtual .build-deps autoconf g++ make \
    && pecl install -o -f pcov \
    && docker-php-ext-enable pcov \
    && pecl clear-cache \
    && apk del .build-deps \
    && rm -rf /tmp/pear \
    && rm -rf /var/cache/apk/*

# install xdebug
RUN apk add --no-cache --update \
    --virtual .build-deps linux-headers $PHPIZE_DEPS \
    && pecl install -f xdebug \
    && docker-php-ext-enable xdebug \
    && pecl clear-cache \
    && apk del .build-deps \
    && rm -rf /tmp/pear \
    && rm -rf /var/cache/apk/*

# install phive
RUN apk add --no-cache --update --virtual .build-deps gnupg \
    && wget -O phive.phar "https://phar.io/releases/phive.phar" \
    && wget -O phive.phar.asc "https://phar.io/releases/phive.phar.asc" \
    && gpg --keyserver hkps://keys.openpgp.org --recv-keys 0x6AF725270AB81E04D79442549D8A98B29B2D5D79 \
    && gpg --verify phive.phar.asc phive.phar \
    && rm phive.phar.asc \
    && chmod +x phive.phar \
    && mv phive.phar /usr/local/bin/phive \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*
