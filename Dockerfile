FROM php:7.1-fpm

ENV DEBIAN_FRONTEND noninteractive

ENV BASE_DIR /usr/src/sylius
ENV SYLIUS_DIR ${BASE_DIR}/app

# All things PHP
RUN mkdir -p ${SYLIUS_DIR} \
	&& chown www-data.www-data ${BASE_DIR} \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
        git \
        vim \
        zlib1g-dev \
		libicu52 \
        libicu-dev \
		libpng-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt4 \
		libmcrypt-dev \
	&& apt-get clean all \
	&& docker-php-ext-enable \
		opcache \
	&& docker-php-ext-install \
		intl \
		zip \
		exif \
		gd \
		pdo \
		pdo_mysql \
		mcrypt \
	&& apt-get purge -y \
		zlib1g-dev \
		libicu-dev \
		libpng-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
	&& apt-get autoremove -y

# All things composer
RUN php -r 'readfile("https://getcomposer.org/installer");' > composer-setup.php \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& rm -f composer-setup.php \
	&& chown www-data.www-data /var/www

# entrypoint.d pattern
COPY entrypoint.sh /entrypoint.sh
COPY entrypoint.d /entrypoint.d

# Operate as www-data in SYLIUS_DIR per default
USER www-data
WORKDIR ${BASE_DIR}

# Speedup composer
RUN composer global require hirak/prestissimo

ENTRYPOINT ["/entrypoint.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]
