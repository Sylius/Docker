FROM php:7.2-fpm-alpine3.8
MAINTAINER Sylius Docker Team <docker@sylius.org>

ENV SYLIUS_VERSION 1.3.2

ENV BASE_DIR /var/www
ENV SYLIUS_DIR ${BASE_DIR}/sylius

# Operate as www-data in SYLIUS_DIR per default
WORKDIR ${BASE_DIR}

RUN apk --no-cache upgrade && \
    apk --no-cache  add curl icu-dev libpng-dev

RUN docker-php-ext-install intl exif gd fileinfo pdo_mysql opcache > /dev/null 2>&1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer

RUN chown www-data:www-data -R ${BASE_DIR};

USER www-data

COPY sylius/sylius-fpm.ini /usr/local/etc/php/conf.d/sylius.ini

RUN composer global require hirak/prestissimo && \
    composer create-project sylius/sylius-standard ${SYLIUS_DIR} ${SYLIUS_VERSION}

COPY sylius/.env ${SYLIUS_DIR}/.env

RUN	chmod +x sylius/bin/console && \
	mkdir -p ${SYLIUS_DIR}/public/media/image

# entrypoint.d scripts
COPY entrypoint.d/* /entrypoint.d/
