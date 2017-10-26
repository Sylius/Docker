include .stub/*.mk

$(eval $(call defw,DOCKER_COMPOSE_LOCAL,docker-compose.local.yml))
$(eval $(call defw,PROJECT,sylius-standard))
$(eval $(call defw,NAME,$(PROJECT)))
$(eval $(call defw,BUILDER_SCOPE,local))

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
up:: assets
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


# -----------------------------------------------------------------------------
# Build helpers
# -----------------------------------------------------------------------------

.PHONY: assets
assets:: ##@Helpers Generate Assets and copy them over to public/build
assets:: node-builder
	@echo "$(TURQUOISE)Running asset builder container"
	@echo "--------------------------------------------------------------------------------$(RESET)"
	docker run \
		--name $(NAME)-node-builder-$(BUILDER_SCOPE) \
		$(NAME)-node-builder:$(BUILDER_SCOPE)

	@echo "$(TURQUOISE)Copying built assets /build/public"
	@echo "--------------------------------------------------------------------------------$(RESET)"
	mkdir -p sylius/web/assets
	docker cp $(NAME)-node-builder-$(BUILDER_SCOPE):/app/web/assets assets
	cp -Rfp assets/* sylius/web/assets
	rm -rf assets/

	@echo "$(TURQUOISE)Remove the container"
	@echo "--------------------------------------------------------------------------------$(RESET)"
	docker rm -f $(NAME)-node-builder-$(BUILDER_SCOPE)

.PHONY: node-builder
node-builder:: ##@Helpers (Re)Build node.js builder
node-builder:: php-builder
	$(shell_env) make _composer

	@echo "$(TURQUOISE)Building the node builder image"
	@echo "--------------------------------------------------------------------------------$(RESET)"
	wget -t 0 https://raw.githubusercontent.com/Sylius/Sylius-Standard/master/package.json
	wget -t 0 https://raw.githubusercontent.com/Sylius/Sylius-Standard/master/yarn.lock
	wget -t 0 https://raw.githubusercontent.com/Sylius/Sylius-Standard/master/Gulpfile.js
	docker build \
		--pull \
		--tag $(NAME)-node-builder:$(BUILDER_SCOPE) \
		-f Dockerfile.build-js \
		.

.PHONY: php-builder
php-builder:: ##@Helpers (Re)build PHP builder
	wget -t 0 https://raw.githubusercontent.com/Sylius/Sylius-Standard/master/composer.json
	wget -t 0 https://raw.githubusercontent.com/Sylius/Sylius-Standard/master/composer.lock
	@echo "$(TURQUOISE)Building PHP builder container"
	@echo "--------------------------------------------------------------------------------$(RESET)"
	docker build \
		--pull \
		--tag $(NAME)-php-builder:$(BUILDER_SCOPE) \
		-f Dockerfile.build-php \
		.

.PHONY: _composer
_composer:: php-builder
	@echo "$(TURQUOISE)Running PHP builder container"
	@echo "--------------------------------------------------------------------------------$(RESET)"
		docker run \
		--name $(NAME)-php-builder-$(BUILDER_SCOPE) \
		$(NAME)-php-builder:$(BUILDER_SCOPE) \
		composer install --no-scripts --ignore-platform-reqs --no-autoloader --no-dev

	@echo "$(TURQUOISE)Extracting PHP builder data"
	@echo "--------------------------------------------------------------------------------$(RESET)"
	mkdir -p sylius/vendor
	mkdir -p docker/cache/composer
	docker cp $(NAME)-php-builder-$(BUILDER_SCOPE):/app/vendor composer-vendor
	docker cp $(NAME)-php-builder-$(BUILDER_SCOPE):/tmp/cache composer-cache
	rsync -qrl composer-vendor/* sylius/vendor/
	rsync -qrl composer-cache/* docker/cache/composer/
	rm -rf composer-vendor
	rm -rf composer-cache

	@echo "$(TURQUOISE)Remove the PHP build container"
	@echo "--------------------------------------------------------------------------------$(RESET)"
	docker rm -f $(NAME)-php-builder-$(BUILDER_SCOPE)
