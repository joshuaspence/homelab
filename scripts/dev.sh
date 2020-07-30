#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Create Kubernetes cluster.
cat <<EOF | kind create cluster --config=-
---
kind: 'Cluster'
apiVersion: 'kind.x-k8s.io/v1alpha4'
nodes:
  - role: 'control-plane'
EOF

# Bootstrap Flux.
./scripts/bootstrap.sh
