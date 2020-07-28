#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Print commands as they are executed, similar to `set -o xtrace`.
function xtrace() {
  # Skip uninteresting commands.
  case "${BASH_COMMAND%% *}" in
    for|if)
      return;;
  esac

  echo "# ${BASH_COMMAND}" | CHART="${CHART:-}" envsubst
}
trap xtrace DEBUG

# Create CRDs first to avoid dependency hell.
kubectl apply --filename=https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
kubectl apply --filename=https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_{alertmanagers,podmonitors,prometheuses,prometheusrules,servicemonitors,thanosrulers}.yaml

# Bootstrap Flux (see https://docs.fluxcd.io/en/1.18.0/tutorials/get-started-helm.html).
kubectl create namespace flux
kubectl apply --filename <(sops --decrypt src/flux/secrets.yaml)
for CHART in flux helm-operator; do
  helm install \
    --namespace "$(yq read "src/flux/${CHART}.yaml" metadata.namespace)" \
    --repo "$(yq read "src/flux/${CHART}.yaml" spec.chart.repository)" \
    --values <(yq read "src/flux/${CHART}.yaml" spec.values) \
    --version "$(yq read "src/flux/${CHART}.yaml" spec.chart.version)" \
    "$(yq read "src/flux/${CHART}.yaml" spec.releaseName)" \
    "$(yq read "src/flux/${CHART}.yaml" spec.chart.name)" \
    >/dev/null
done

# Force a sync.
# NOTE: We use `retry` to workaround https://github.com/fluxcd/flux/issues/3200.
kubectl --namespace flux rollout status deployment/flux
kubectl --namespace flux rollout status deployment/helm-operator
retry --delay=5 --times=10 -- fluxctl --k8s-fwd-ns flux sync

# Wait for all Helm releases to be installed.
kubectl wait --all --all-namespaces --for condition=released --timeout 10m helmrelease
