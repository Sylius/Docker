include .stub/*.mk

$(eval $(call defw,DOCKER_COMPOSE_LOCAL,docker-compose.local.yml))
$(eval $(call defw,PROJECT,sylius-standard))
$(eval $(call defw,NAME,$(PROJECT)))

UNAME_S := $(shell uname -s)

ifneq ("$(wildcard $(DOCKER_COMPOSE_LOCAL))","")
    DOCKER_COMPOSE_EXTRA_OPTIONS := -f $(DOCKER_COMPOSE_LOCAL)
endif

ifeq (Linux,$(UNAME_S))
    $(eval $(call defw,AS_UID,$(shell id -u)))
endif

# Deps
has_created_containers := $(shell docker ps -a -f "name=${NAME}" --format="{{.ID}}")


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

.PHONY: rm
rm:: ##@Compose Clean docker-compose stack
	docker-compose \
		rm \
		--force

ifneq ($(has_created_containers),)
	docker rm -f $(has_created_containers)
endif

.PHONY: shell
shell:: ##@Development Bring up a shell
	docker exec \
		-ti \
        -u www-data \
		${NAME}-app \
		bash

.PHONY: create-project
create-project::
	docker exec \
		-it \
	-u www-data \
		${NAME}-app \
	composer create-project sylius/sylius-standard sylius 1.1.1 && chmod +x sylius/bin/console

.PHONY: console
console:: ##@Development Call Symfony "console" with "console [<CMD>]"
	docker exec \
		-ti \
		-u www-data \
		${NAME}-app \
		sylius/bin/console $(CMD)
