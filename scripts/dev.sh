#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Create Kubernetes cluster.
kind create cluster

# Bootstrap Flux.
./scripts/bootstrap.sh

# Add routes for MetalLB.
for ADDRESS in $(yq read src/kube-system/metallb.yaml 'spec.values.configInline.address-pools[*].addresses[*]'); do
  sudo ip route replace "${ADDRESS}" dev "br-$(docker network ls --filter name=kind --quiet)"
done
