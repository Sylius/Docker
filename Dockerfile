FROM sylius/nginx-php-fpm:latest
MAINTAINER Sylius Docker Team <docker@sylius.org>

ENV SYLIUS_VERSION 1.1@dev

ENV BASE_DIR /var/www
ENV SYLIUS_DIR ${BASE_DIR}/sylius

# Operate as www-data in SYLIUS_DIR per default
WORKDIR ${BASE_DIR}

# Create Sylius project
RUN composer create-project sylius/sylius-standard ${SYLIUS_DIR} ${SYLIUS_VERSION} \
	&& chmod +x sylius/bin/console

ENTRYPOINT ["/entrypoint.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]
