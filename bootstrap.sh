#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Bootstrap Flux.
kubectl create namespace flux
fluxctl install --git-email support@weave.works --git-url $(gh api repos/:owner/:repo | jq --raw-output .ssh_url) --namespace flux | kubectl apply --filename -
kubectl --namespace flux rollout status deployment/flux

# Add SSH key to repo.
gh api repos/:owner/:repo/keys | jq '.[] | .id' | xargs --replace gh api repos/:owner/:repo/keys/{} --method DELETE
fluxctl --k8s-fwd-ns flux identity | gh api repos/:owner/:repo/keys --field 'title=Flux' --field 'key=@-' --field 'read_only=false'
