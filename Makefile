SHELL := /bin/bash

PIGEN_SOURCE := git@github.com:RPi-Distro/pi-gen.git
PIGEN_VERSION := 7bbaac3344807e81d491a859168c83ef469a250f

default: help

all: hostdeps checks pi-gen build

.PHONY = build
build: checks hostdeps pi-gen  ## Build the pax image
	./build_pax.sh

.PHONY = hostdeps
hostdeps: .hostdeps  ## Install host dependencies

.PHONY = checks
checks:
	@if ! which docker 2>&1 > /dev/null; then \
	  echo "Build cannot proceed without installing docker"; \
	  echo "  curl -sSL https://get.docker.com/ | sh"; \
	  exit 1; \
	fi

pi-gen: ## Download the pi-gen source code and check the right version
	@echo "# Cloning $@"
	git clone $(PIGEN_SOURCE) "$@"

	@# Checkout the right version
	cd "$@" && git checkout -b pax-gen $(PIGEN_VERSION)

.hostdeps:
	@# Install dependencies
	@# This may not be needed.  Remove after testing with a new OS install.
	@echo "Installing build machine dependencies"
	@#sudo apt-get -yq install quilt qemu-user-static debootstrap kpartx pxz zip bsdtar
	@#touch .hostdeps

mrclean:  ## Delete all non-repository files
	rm -rf pi-gen .hostdeps ./docker

help: ## Print list of Makefile targets
	@# Taken from https://github.com/spf13/hugo/blob/master/Makefile
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
