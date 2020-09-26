#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Create a custom Docker network.
if ! docker network inspect homelab &>/dev/null; then
  docker network create \
    --driver bridge \
    --ip-range 172.100.0.0/24 \
    --opt com.docker.network.bridge.enable_ip_masquerade=true \
    --subnet 172.100.0.0/16 \
    homelab
fi
export KIND_EXPERIMENTAL_DOCKER_NETWORK=homelab

# Create Kubernetes cluster.
#
# TODO: Load Docker images with `kind load docker-image`.
kind create cluster

# Bootstrap Flux.
./scripts/bootstrap.sh
