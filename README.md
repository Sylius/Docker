# Sylius Docker Environment

[![Build Status](https://travis-ci.org/Sylius/Docker.svg?branch=master)](https://travis-ci.org/Sylius/Docker)

This project is intended as boilerplate and for bootstrapping your 100% dockerized Sylius development environment. It can also be used as blueprint to use in an automated deployment pipeline achieving Dev/Prod-Parity.

The development environment consists of 3 containers, running

  * nginx and php-fpm (7.1) using [sylius/docker-nginx-php-fpm](https://hub.docker.com/r/sylius/nginx-php-fpm/) as base image
  * Percona 5.7 as database
  * [MailHog](https://github.com/mailhog/MailHog) for testing outgoing email

You can control, customize and extend the behaviour of this environment with ``make`` - see ``make help`` for details. It is built around the principles and ideas of the [Docker Make Stub](https://github.com/25th-floor/docker-make-stub).

# Development

## Requirements

Because ``docker-compose.yml`` uses Compose file format 2.1 at least **Docker version 1.12** ist required for this environment.

## Quickstart

```
git clone https://github.com/sylius/docker sylius-docker
make help
make up
make console CMD=sylius:install
```

## Accessing services and ports

| Service        | Port  | Internal DNS | Exported |
|----------------|-------|--------------|----------|
| Sylius (HTTP)  | 8000  | sylius       | Yes      |
| MySQL          | 3606  | mysql        | Yes      |
| MailHog (SMTP) | 1025  | mailhog      | No       |
| MailHog (HTTP) | 8025  | mailhog      | Yes      |

## Customizing docker-compose.yml

You can create a ``docker-compose.local.yml`` to further extend the docker-compose configuration by overloading the existing YAML configuration. If this file exists ``make up`` will recognize and add it as ``-f docker-compose.local.yml`` when executing docker-compose.

For example:

```yaml
version: '2'

services:
  sylius:
    environments:
      - ADDITIONAL_ENV=yesplease
```

Please note array elements (ports, environments, volumes, ...) will get **merged** and **not replaced**. If you want to see this happen have a look at [https://github.com/docker/compose/pull/3939](https://github.com/docker/compose/pull/3939) and vote for this PR.

To change the e.g. exposed ports for your local environment you have to edit ``docker-compose.yml`` for now.

## Running Symfony Console

You can always execute Symfony Console either by getting an interactive shell in the application container using ``make shell``. For some a more convenient way might be using ``make console`` which is a wrapper for that.

When using the wrapper target you can pass arguments to ``console`` by using the ``CMD`` variable:

```bash
make console CMD=sylius:install
make console CMD="sylius:user:promote awesome@sylius.org"
make console CMD="sylius:theme:assets:install web --symlink --relative"
```

# Support for you Deployment Pipeline

TODO

# Todo

  * Integrate an Asset Builder
  * Run ``sylius:install`` when required
  * Run ``composer create-project`` when required (required for volume mount)
  * ~~[PR #15](https://github.com/Sylius/Docker/pull/15): Predefine project and network name (currently docker-compose generates one based on the root directory name)~~
