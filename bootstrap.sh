#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Print commands as they are executed.
trap 'echo "# $BASH_COMMAND"' DEBUG

# Create deployment key and upload to GitHub.
readonly FLUX_KEY="${HOME}/.ssh/keys/flux"

if ! test -f "${FLUX_KEY}"; then
  ssh-keygen -C flux -f "${FLUX_KEY}" -N '' -q -t ed25519

  gh api repos/:owner/:repo/keys | jq '.[] | .id' | xargs --replace gh api repos/:owner/:repo/keys/{} --method DELETE
  gh api repos/:owner/:repo/keys --field 'title=Flux' --field "key=@${FLUX_KEY}.pub" --field 'read_only=false' >/dev/null
fi

# Bootstrap Flux (see https://docs.fluxcd.io/en/1.18.0/tutorials/get-started-helm.html).
kubectl create namespace flux
kubectl --namespace flux create secret generic flux-git-deploy --from-file "identity=${FLUX_KEY}"
helm install --namespace flux --repo https://charts.fluxcd.io --set git.path=deployments --set git.secretName=flux-git-deploy --set git.url=$(gh api repos/:owner/:repo | jq --raw-output .ssh_url) --wait flux flux >/dev/null
helm install --namespace flux --repo https://charts.fluxcd.io --set helm.versions=v3 helm-operator --wait helm-operator >/dev/null

# Force a sync.
fluxctl --k8s-fwd-ns flux sync
