#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Configure `fluxctl`.
export FLUX_FORWARD_NAMESPACE=flux

# Print commands as they are executed.
trap 'echo "# $BASH_COMMAND"' DEBUG

# Apply the `HelmRelease` CRD.
kubectl apply --filename https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml

# Create SSH key and upload to GitHub.
if ! test -f ~/.ssh/keys/flux; then
  ssh-keygen -C flux -f ~/.ssh/keys/flux -N '' -q -t ed25519

  gh api repos/:owner/:repo/keys | jq '.[] | .id' | xargs --replace gh api repos/:owner/:repo/keys/{} --method DELETE
  gh api repos/:owner/:repo/keys --field 'title=Flux' --field "key=@${HOME}/.ssh/keys/flux.pub" --field 'read_only=false' >/dev/null
fi

# Bootstrap Flux (see https://docs.fluxcd.io/en/1.18.0/tutorials/get-started-helm.html).
kubectl create namespace flux
kubectl --namespace flux create secret generic flux-git-deploy --from-file "identity=${HOME}/.ssh/keys/flux"
helm install --namespace flux --repo https://charts.fluxcd.io --set git.path=deployments --set git.secretName=flux-git-deploy --set git.url=$(gh api repos/:owner/:repo | jq --raw-output .ssh_url) --wait flux flux >/dev/null
helm install --namespace flux --repo https://charts.fluxcd.io --set helm.versions=v3 helm-operator --wait helm-operator >/dev/null

# Force a sync.
fluxctl sync
