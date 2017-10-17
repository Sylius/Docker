include .stub/*.mk

.PHONY: build
build:: ##@Docker Build the Sylius application image
	docker build \
		-f Dockerfile \
		.

.PHONY: up
up:: ##@Sylius Start the Sylius stack for development (using docker-compose)
	docker-compose \
		-f docker-compose.yml \
		up \
		--build

.PHONY: shell
shell:: ##@Development Bring up a shell
	docker exec \
		-ti \
		syliusdocker_sylius_1 \
		bash

.PHONY: console
console:: ##@Development Call Symfony "console" with "console [<CMD>]"
	docker exec \
		-ti \
		-u www-data \
		syliusdocker_sylius_1 \
		sylius/bin/console $(CMD)
