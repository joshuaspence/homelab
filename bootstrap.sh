#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Add Helm repository for Flux.
helm repo add fluxcd https://charts.fluxcd.io

# Bootstrap Flux and Helm Operator.
kubectl apply --filename flux/namespace.yaml
helm install --namespace flux --set git.readonly=true --set git.url=https://github.com/joshuaspence/homelab.git flux fluxcd/flux
helm install --namespace flux --set helm.versions=v3 helm-operator fluxcd/helm-operator

# --atomic
# --no-hooks
# --repo
# --verify
# --wait

