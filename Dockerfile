FROM php:7.2-fpm-alpine3.8
MAINTAINER Sylius Docker Team <docker@sylius.org>

ENV SYLIUS_VERSION 1.3.2

ENV BASE_DIR /var/www
ENV SYLIUS_DIR ${BASE_DIR}/sylius

# Operate as www-data in SYLIUS_DIR per default
WORKDIR ${BASE_DIR}

RUN mkdir -p ${SYLIUS_DIR} && chown www-data:www-data ${SYLIUS_DIR}

RUN apk --no-cache upgrade && \
    apk --no-cache  add curl icu-dev libpng-dev

RUN docker-php-ext-install intl exif gd fileinfo pdo_mysql opcache > /dev/null 2>&1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

COPY sylius/sylius-fpm.ini /usr/local/etc/php/conf.d/sylius.ini
COPY sylius/.env ${SYLIUS_DIR}/.env

# Create Sylius project
USER www-data

RUN composer global require hirak/prestissimo

RUN composer create-project \
		sylius/sylius-standard \
		${SYLIUS_DIR} \
		${SYLIUS_VERSION} \
	&& chmod +x sylius/bin/console \
	&& mkdir -p ${SYLIUS_DIR}/public/media/image
#	&& cd ${SYLIUS_DIR} \
#	&& bin/console sylius:install

USER root

# entrypoint.d scripts
COPY entrypoint.d/* /entrypoint.d/

# nginx configuration
#COPY nginx/nginx.conf /etc/nginx/nginx.conf
#COPY nginx/sylius_params /etc/nginx/sylius_params

#RUN chown www-data.www-data /etc/nginx/sylius_params
