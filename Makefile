# Mute all `make` specific output. Comment this out to get some debug information.
.SILENT:
MAKEFLAGS += --no-print-directory
SHELL=/bin/bash
EXEC_SHELL=/bin/bash

UID="$(shell id -u)"
GID="$(shell id -g)"
ENV_VARS=env UID=${UID} GID=${GID}

# create new container and run
PHP_CLI_RUN=$(ENV_VARS) docker compose -f build/docker-compose.yaml run --rm app
PHP_CLI_RUN_ROOT=docker compose -f build/docker-compose.yaml run --rm app
# login to running container and execute
PHP_CLI_EXEC=$(ENV_VARS) docker compose -f build/docker-compose.yaml exec app
PHP_CLI_EXEC_ROOT=docker compose -f build/docker-compose.yaml exec --user 0:0 app

ifneq ("$(wildcard Makefile.vars.local.mk)","")
  include Makefile.vars.local.mk
endif

# .DEFAULT: If the command does not exist in this makefile
# default: If no command was specified
.DEFAULT default:
	if [ -f ./Makefile.custom.mk ]; then \
	    $(MAKE) -f Makefile.custom.mk "$@"; \
	else \
	    if [ "$@" != "default" ]; then echo "Command '$@' not found."; fi; \
	    $(MAKE) help; \
	    if [ "$@" != "default" ]; then exit 2; fi; \
	fi

help:  ## Show this help
	@echo "Usage:"
	@echo "     [ENV=VALUE] [...] make [command] [ARG=VALUE]"
	@echo "     make my-target"
	@echo "     NAMESPACE=\"dummy-app-namespace\" RELEASE_NAME=\"another-dummy-app\" make my-target"
	@echo
	@echo "Available commands:"
	@grep '^[^#[:space:]].*:' Makefile | grep -v '^default' | grep -v '^\.' | grep -v '=' | grep -v '^_' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-50s\033[0m %s\n", $$1, $$2}' | sed 's/://'

init: init-dev-folders init-local-vars-files init-php-configs init-composer-dependencies dev

init-dev-folders:
	mkdir -p var/cache
	mkdir -p var/xdebug
	mkdir -p var/logs

init-local-vars-files:
	if [ ! -f .env ]; then cp .env.dist .env || echo ".env already exists, skipping copy."; fi
	if [ ! -f Makefile.local.mk ]; then echo "# You can place your own make targets in this file" > Makefile.local.mk; fi
	if [ ! -f Makefile.vars.local.mk ]; then echo "# You can place your own makefile variables overrides in this file" > Makefile.vars.local.mk; fi

init-php-configs:
	if [ ! -f build/php.ini ]; then cp build/php.ini.dist build/php.ini; fi
	if [ ! -f build/xdebug.ini ]; then cp build/xdebug.ini.dist build/xdebug.ini; fi
	if [ ! -f build/opcache.ini ]; then cp build/opcache.ini.dist build/opcache.ini; fi

init-composer-dependencies:
	$(PHP_CLI_EXEC) composer install

up: init-dev-folders init-local-vars-files init-php-configs
	$(ENV_VARS) docker compose -f build/docker-compose.yaml up -d

php:
	$(PHP_CLI_EXEC) /bin/bash

php-root: 	## Login to the running php service, as root
	$(PHP_FPM_EXEC_ROOT) /bin/bash

down:
	$(ENV_VARS) docker compose -f build/docker-compose.yaml down

composer-install:
	$(PHP_CLI_EXEC) composer install

composer-update:
	$(PHP_CLI_EXEC) composer update

arkitect:
	$(PHP_CLI) composer arkitect

arkitect-baseline:
	$(PHP_CLI) composer arkitect-baseline

cs: init-dev-folders
	$(PHP_CLI_EXEC) composer cs-fix

stan: init-dev-folders
	$(PHP_CLI_EXEC) composer phpstan

rector: init-dev-folders
	$(PHP_CLI) composer rector-fix

xon:	## Turn on Xdebug from the host
	$(PHP_FPM_EXEC) make .xon

.xon:	## Turn on Xdebug from within the php-fpm container
	./scripts/xdebug.sh on

xoff:	## Turn off Xdebug from the host
	$(PHP_FPM_EXEC) make .xoff

.xoff:	## Turn off Xdebug from within the php-fpm container
	./scripts/xdebug.sh off

test-ci:		## Run the tests as they run in the CI (without fixing anything), from outside the container
	$(PHP_FPM_EXEC) make .test-ci

.test-ci:	## Run the tests as they run in the CI (without fixing anything), except Dusk, from inside the container
	echo
	echo "==========> Rector"
	echo
	composer rector-check

	echo
	echo "==========> CS Fixer"
	echo
	composer cs-check

	echo
	echo "==========> PHPStan"
	echo
	composer phpstan

#	echo
#	echo "==========> Arkitect"
#	echo
#	composer arkitect

	echo
	echo "==========> PHPUnit"
	echo
	composer phpunit-cov

test-dev:	## Run the tests that run in the CI but in dev mode (making fixes), from outside the container
	make xoff
	$(PHP_FPM_EXEC) make .test-dev

.test-dev:	## Run the tests that run in the CI but in dev mode (making fixes), except Dusk, from inside the container
	echo
	echo "==========> Rector"
	echo
	composer rector-fix

	echo
	echo "==========> CS Fixer"
	echo
	composer cs-fix

	echo
	echo "==========> PHPStan"
	echo
	composer phpstan

#	echo
#	echo "==========> Arkitect"
#	echo
#	composer arkitect

	echo
	echo "==========> PHPUnit"
	echo
	composer phpunit

ifneq ("$(wildcard Makefile.local.mk)","")
  include Makefile.local.mk
endif
