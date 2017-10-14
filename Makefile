include *.mk

.PHONY: up
up:: ##@Compose Start from docker-compose.yml (attached)
	docker-compose \
		-f docker-compose.yml \
		up \
		--build
