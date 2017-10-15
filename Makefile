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
shell:: ##@Sylius Bring up a shell
	docker exec \
		-ti \
		syliusdocker_sylius_1 \
		bash
