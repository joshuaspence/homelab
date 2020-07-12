#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Configure `fluxctl`.
export FLUX_FORWARD_NAMESPACE=flux

# Add the Flux repository.
helm repo add fluxcd https://charts.fluxcd.io

# Apply the `HelmRelease` CRD.
kubectl apply --filename https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml

# Bootstrap Flux (see https://docs.fluxcd.io/en/1.18.0/tutorials/get-started-helm.html).
kubectl create namespace flux
helm install --atomic --namespace flux --set git.path=deployments --set git.url=$(gh api repos/:owner/:repo | jq --raw-output .ssh_url) flux fluxcd/flux
helm install --atomic --namespace flux --set helm.versions=v3 helm-operator fluxcd/helm-operator

# Add SSH key to repo.
gh api repos/:owner/:repo/keys | jq '.[] | .id' | xargs --replace gh api repos/:owner/:repo/keys/{} --method DELETE
fluxctl identity | gh api repos/:owner/:repo/keys --field 'title=Flux' --field 'key=@-' --field 'read_only=false'

# Force a sync.
fluxctl sync
