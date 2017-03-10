SHELL := /bin/bash

SOURCE := git@github.com:dcwangmit01/pax-gen.git
PIGEN_SOURCE := git@github.com:RPi-Distro/pi-gen.git

.PHONY = build pi-gen

build: pi-gen
	./build_pax.sh

pi-gen:
	@echo "# Cloning $@"
	git clone $(PIGEN_SOURCE) "$@"
	@# Ensure a fork and checkout the right version
	pushd pi-gen && \
	  hub fork || true && \
	  git fetch --all && \
	  git checkout -b current dcwangmit01/make_workdir_deploydir_configurable || true && \
	  popd

