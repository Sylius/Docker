include .stub/*.mk

$(eval $(call defw,DOCKER_COMPOSE_LOCAL,docker-compose.local.yml))

ifneq ("$(wildcard $(DOCKER_COMPOSE_LOCAL))","")
	DOCKER_COMPOSE_EXTRA_OPTIONS := -f $(DOCKER_COMPOSE_LOCAL)
endif


.PHONY: build
build:: ##@Docker Build the Sylius application image
	docker build \
		-f Dockerfile \
		.

.PHONY: up
up:: ##@Sylius Start the Sylius stack for development (using docker-compose)
	docker-compose \
		-f docker-compose.yml \
		$(DOCKER_COMPOSE_EXTRA_OPTIONS) \
		up \
		--build

.PHONY: shell
shell:: ##@Development Bring up a shell
	docker exec \
		-ti \
		docker_sylius_1 \
		bash

.PHONY: console
console:: ##@Development Call Symfony "console" with "console [<CMD>]"
	docker exec \
		-ti \
		-u www-data \
		docker_sylius_1 \
		sylius/bin/console $(CMD)
