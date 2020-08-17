#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly PUBLIC_KEY=$(
  sops --decrypt src/flux/secrets.sops.yaml |
    yq read --collect --doc '*' - |
    yq read - '(metadata.name==flux-git-deploy).data.identity' |
    base64 --decode |
    ssh-keygen -f /dev/stdin -y
)

# Check if deployment key already exists.
if gh api repos/:owner/:repo/keys | jq --exit-status --arg public_key "${PUBLIC_KEY}" '.[] | select(.key == $public_key)' >/dev/null; then
  echo 'Deployment key already exists.'
  exit 0
fi

# Delete existing deployment key.
gh api repos/:owner/:repo/keys |
  jq '.[] | select(.title == "Flux") | .id' |
  xargs --replace gh api --method DELETE repos/:owner/:repo/keys/{}

# Create a new deployment key.
gh api \
  --field 'title=Flux' \
  --field "key=${PUBLIC_KEY}" \
  --field 'read_only=false' \
  repos/:owner/:repo/keys
