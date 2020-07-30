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
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: 'TCP'
      - containerPort: 443
        hostPort: 443
        protocol: 'TCP'
EOF

# Bootstrap Flux.
./scripts/bootstrap.sh

# Make ingress work (see https://kind.sigs.k8s.io/docs/user/ingress#using-ingress).
kubectl --namespace "$(yq read src/kube-system/nginx-ingress.yaml metadata.namespace)" patch deployment nginx-ingress-controller --patch "$(cat <<EOF
---
spec:
  template:
    spec:
      containers:
        - name: 'nginx-ingress-controller'
          ports:
            - containerPort: 80
              hostPort: 80
            - containerPort: 443
              hostPort: 443
EOF
)"
