FROM sylius/nginx-php-fpm:latest
MAINTAINER Sylius Docker Team <docker@sylius.org>

ARG AS_UID=33

ENV SYLIUS_VERSION 1.1.1

ENV BASE_DIR /var/www
ENV SYLIUS_DIR ${BASE_DIR}/sylius

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    nodejs

# Install NodeJs dependencies
RUN npm install -g yarn gulp

#Modify UID of www-data into UID of local user
RUN usermod -u ${AS_UID} www-data

# Operate as www-data in SYLIUS_DIR per default
WORKDIR ${BASE_DIR}

USER root

# entrypoint.d scripts
COPY entrypoint.d/* /entrypoint.d/

# nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sylius_params /etc/nginx/sylius_params

RUN chown www-data.www-data /etc/nginx/sylius_params
