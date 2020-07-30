#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Create Kubernetes cluster.
cat <<EOF | kind create cluster --config=-
---
apiVersion: 'kind.x-k8s.io/v1alpha4'
kind: 'Cluster'
nodes:
  - role: 'control-plane'
  - role: 'worker'
  - role: 'worker'
EOF

# Bootstrap Flux.
./scripts/bootstrap.sh
