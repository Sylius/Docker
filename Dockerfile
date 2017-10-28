FROM sylius/nginx-php-fpm:latest
MAINTAINER Sylius Docker Team <docker@sylius.org>

ENV SYLIUS_VERSION dev-master

ENV BASE_DIR /var/www
ENV SYLIUS_DIR ${BASE_DIR}/sylius

#Modify UID of www-data into UID of local user
ARG AS_UID=33
RUN usermod -u ${AS_UID} www-data

# Operate as www-data in SYLIUS_DIR per default
WORKDIR ${BASE_DIR}

# Create Sylius project
USER www-data
RUN composer create-project \
		sylius/sylius-standard \
		${SYLIUS_DIR} \
		${SYLIUS_VERSION} \
	&& chmod +x sylius/bin/console
USER root

# entrypoint.d scripts
COPY entrypoint.d/* /entrypoint.d/

# nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sylius_params /etc/nginx/sylius_params

RUN chown www-data.www-data /etc/nginx/sylius_params
