#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

function bootstrap_release() {
  kubectl apply --filename "bootstrap/${1}/${1}-release-values.yaml"
  helm --namespace flux upgrade --install --values <(kubectl --namespace flux get --output jsonpath='{.data.values\.yaml}' configmap "${1}-release-values") --wait "${1}" "fluxcd/${1}"
}

# Add Helm repository for Flux.
helm repo add fluxcd https://charts.fluxcd.io

# Bootstrap Flux and Helm Operator.
kubectl apply --filename bootstrap/namespace.yaml
bootstrap_release flux
bootstrap_release helm-operator
