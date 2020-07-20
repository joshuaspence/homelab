#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Create deployment key and upload to GitHub.
readonly FLUX_KEY="${HOME}/.ssh/keys/flux"

if ! test -f "${FLUX_KEY}"; then
  # Generate a new key.
  ssh-keygen -C flux -f "${FLUX_KEY}" -N '' -q -t ed25519

  # Delete existing deployment keys.
  gh api repos/:owner/:repo/keys | jq '.[] | .id' | xargs --replace gh api repos/:owner/:repo/keys/{} --method DELETE

  # Create a new deployment key.
  gh api repos/:owner/:repo/keys --field 'title=Flux' --field "key=@${FLUX_KEY}.pub" --field 'read_only=false' >/dev/null
fi

# Print commands as they are executed.
trap 'echo "# $BASH_COMMAND"' DEBUG

# Create CRDs first to avoid dependency hell.
kubectl apply --filename https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
for CRD in alertmanagers podmonitors prometheuses prometheusrules servicemonitors thanosrulers; do
  kubectl apply --filename "https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_${CRD}.yaml"
done

# Bootstrap Flux (see https://docs.fluxcd.io/en/1.18.0/tutorials/get-started-helm.html).
kubectl create namespace flux
kubectl --namespace flux create secret generic flux-git-deploy --from-file "identity=${FLUX_KEY}"
for CHART in helm-operator flux; do
  helm install --namespace $(yq read "src/flux/${CHART}.yaml" metadata.namespace) --repo $(yq read "src/flux/${CHART}.yaml" spec.chart.repository) --values <(yq read "src/flux/${CHART}.yaml" spec.values) --version $(yq read "src/flux/${CHART}.yaml" spec.chart.version) --wait $(yq read "src/flux/${CHART}.yaml" spec.releaseName) $(yq read "src/flux/${CHART}.yaml" spec.chart.name) >/dev/null
done

# Force a sync.
# NOTE: We use `retry` to workaround https://github.com/fluxcd/flux/issues/3200.
retry --delay=10 --times=12 -- fluxctl --k8s-fwd-ns flux sync

# Wait for all Helm releases to be installed.
kubectl wait --all --all-namespaces --for condition=released --timeout 10m helmrelease
