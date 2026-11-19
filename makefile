.PHONY: help build
.DEFAULT_GOAL := help

help:
	@echo "PROJECT COMMANDS"
	@echo "--------------------------------------------------------------------------------------------"
	@printf "\033[33mInstallation:%-30s\033[0m %s\n"
	@grep -E '^[a-zA-Z_-]+:.*?##1 .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?##1 "}; {printf "\033[33m  - %-30s\033[0m %s\n", $$1, $$2}'
	@echo "--------------------------------------------------------------------------------------------"
	@printf "\033[36mDevelopment:%-30s\033[0m %s\n"
	@grep -E '^[a-zA-Z_-]+:.*?##2 .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?##2 "}; {printf "\033[36m  - %-30s\033[0m %s\n", $$1, $$2}'
	@echo "--------------------------------------------------------------------------------------------"
	@printf "\033[35mDevOps:%-30s\033[0m %s\n"
	@grep -E '^[a-zA-Z_-]+:.*?##3 .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?##3 "}; {printf "\033[35m  - %-30s\033[0m %s\n", $$1, $$2}'
	@echo "--------------------------------------------------------------------------------------------"
	@printf "\033[32mTests:%-30s\033[0m %s\n"
	@grep -E '^[a-zA-Z_-]+:.*?##4 .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?##4 "}; {printf "\033[32m  - %-30s\033[0m %s\n", $$1, $$2}'

# ----------------------------------------------------------------------------------------------------------------
#// Installation

install: ##1 Installs the test dependencies (SVRUnit) with Composer in Docker
	docker run --rm -u "$$(id -u):$$(id -g)" -e COMPOSER_HOME=/tmp/composer -v "$(CURDIR)":/app -w /app composer:2 install --no-interaction

clear: ##1 Clears all dangling images
	docker images -aq -f 'dangling=true' | xargs docker rmi
	docker volume ls -q -f 'dangling=true' | xargs docker volume rm

# ----------------------------------------------------------------------------------------------------------------
#// Building
all: ##2 Helper that builds, tests and analyzes the image
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
	make build version=$(version)
	make svrunit version=$(version)
	make analyze version=$(version)

# ----------------------------------------------------------------------------------------------------------------

build: ##3 Builds the proxy image
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
	DOCKER_BUILDKIT=1 docker build --pull --no-cache --build-arg IMAGE_VERSION=$(version) -t dockware/proxy:$(version) ./src

analyze: ##3 Shows the size of the image
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
	docker history --format "{{.CreatedBy}}\t\t{{.Size}}" dockware/proxy:$(version) | grep -v "0B"
	# --------------------------------------------------
	docker save -o proxy.tar dockware/proxy:$(version)
	gzip proxy.tar
	ls -lh proxy.tar.gz
	# --------------------------------------------------
	rm -rf proxy.tar
	rm -rf proxy.tar.gz | true

# ----------------------------------------------------------------------------------------------------------------
#// Tests

svrunit: ##4 Runs all SVRUnit tests against the local image dockware/proxy:<version>
ifndef version
	$(error Please provide the argument version=xyz to run the command)
endif
	php ./vendor/bin/svrunit test --configuration=./tests/svrunit/suite.xml --docker-tag=$(version) --debug --report-junit --report-html
