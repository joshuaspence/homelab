#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Print commands as they are executed.
trap 'echo "# $BASH_COMMAND"' DEBUG

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

# Create CRDs first to avoid dependency hell.
kubectl apply --filename https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
for CRD in alertmanagers podmonitors prometheuses prometheusrules servicemonitors thanosrulers; do
  kubectl apply --filename "https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/monitoring.coreos.com_${CRD}.yaml"
done

# Bootstrap Flux (see https://docs.fluxcd.io/en/1.18.0/tutorials/get-started-helm.html).
kubectl create namespace flux
kubectl --namespace flux create secret generic flux-git-deploy --from-file "identity=${FLUX_KEY}"
for CHART in helm-operator flux; do
  helm install --namespace flux --repo https://charts.fluxcd.io --values <(yq read "src/flux/${CHART}.yaml" spec.values) --wait "${CHART}" "${CHART}" >/dev/null
done

# Force a sync.
fluxctl --k8s-fwd-ns flux sync
