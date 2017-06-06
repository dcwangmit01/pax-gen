#!/bin/bash
set -euo pipefail
set -x

# Load the docker images if they haven't been already
cd /opt/docker/images
for _file in *.docker.tar.gz; do
    check_file=".loaded.$_file"
    if [ -f "$check_file" ]; then
	continue
    fi
    zcat "$_file" | docker load
    touch "$check_file"
done

# Do docker-compose up if the docker-compose file exists
cd /opt/docker
if [ -f docker-compose.yaml ]; then
    docker-compose up -d
fi
