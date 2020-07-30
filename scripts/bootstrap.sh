#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Print commands as they are executed, similar to `set -o xtrace`.
function xtrace() {
  case "${BASH_COMMAND%% *}" in
    # Skip uninteresting commands.
    for)
      return
      ;;

    *)
      echo "# ${BASH_COMMAND}" | CHART="${CHART:-}" envsubst
      ;;
  esac
}
trap xtrace DEBUG

# Create CRDs first to avoid dependency hell.
kubectl apply --filename https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

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
    "$(yq read "src/flux/${CHART}.yaml" spec.chart.name)"
done

# Force a sync.
# NOTE: We use `retry` to workaround https://github.com/fluxcd/flux/issues/3200.
kubectl --namespace flux rollout status deployment/flux
kubectl --namespace flux rollout status deployment/helm-operator
retry --delay 5 --times 10 -- fluxctl --k8s-fwd-ns flux sync

# Wait for all Helm releases to be installed.
kubectl wait --all --all-namespaces --for condition=released --timeout 10m helmrelease
