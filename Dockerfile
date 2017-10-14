FROM php:7.1-fpm

ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /usr/src/sylius \
	&& chown www-data.www-data /usr/src/sylius \
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

# install composer
RUN php -r 'readfile("https://getcomposer.org/installer");' > composer-setup.php \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& rm -f composer-setup.php \
	&& chown www-data.www-data /var/www

COPY entrypoint.sh /entrypoint.sh
COPY entrypoint.d /entrypoint.d

USER www-data
RUN composer global require hirak/prestissimo
WORKDIR /usr/src/sylius

ENTRYPOINT ["/entrypoint.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]
