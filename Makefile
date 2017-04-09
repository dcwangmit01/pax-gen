SHELL := /bin/bash

PIGEN_SOURCE := git@github.com:RPi-Distro/pi-gen.git
PIGEN_VERSION := 16b3133f4641e58ceb1e67250c5c685dfd50ad6e

default: help

all: hostdeps

.PHONY = build
build: hostdeps pi-gen  ## Build the pax image
	./build_pax.sh

.PHONY = hostdeps
hostdeps: .hostdeps  ## Install host dependencies


pi-gen: ## Download the pi-gen source code and check the right version
	@echo "# Cloning $@"
	git clone $(PIGEN_SOURCE) "$@"

	@# Checkout the right version
	cd "$@" && git checkout -b pax-gen $(PIGEN_VERSION)

.hostdeps:
	@# Install dependencies
	@echo "Installing build machine dependencies"
	sudo apt-get -yq install quilt qemu-user-static debootstrap kpartx pxz zip bsdtar
	touch .hostdeps

mrclean:  ## Delete all non-repository files
	rm -rf pi-gen .hostdeps

help: ## Print list of Makefile targets
	@# Taken from https://github.com/spf13/hugo/blob/master/Makefile
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
