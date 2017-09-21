FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl apt-transport-https apt-utils build-essential
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update &&  apt-get install yarn
RUN yarn global add gulp 

WORKDIR /var/www/sylius
RUN yarn install

CMD ["gulp", "default"]
