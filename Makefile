include .stub/*.mk

$(eval $(call defw,DOCKER_COMPOSE_LOCAL,docker-compose.local.yml))
$(eval $(call defw,PROJECT,sylius-standard))
$(eval $(call defw,NAME,$(PROJECT)))

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
		-p $(PROJECT) \
		$(DOCKER_COMPOSE_EXTRA_OPTIONS) \
		up \
		--build

.PHONY: shell
shell:: ##@Development Bring up a shell
	docker exec \
		-ti \
		${NAME}-app \
		bash

.PHONY: console
console:: ##@Development Call Symfony "console" with "console [<CMD>]"
	docker exec \
		-ti \
		-u www-data \
		${NAME}-app \
		sylius/bin/console $(CMD)
