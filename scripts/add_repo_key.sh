#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Delete existing deployment key.
gh api repos/:owner/:repo/keys |
  jq '.[] | select(.title == "Flux") | .id' |
  xargs --replace gh api --method DELETE repos/:owner/:repo/keys/{}

# Create a new deployment key.
gh api \
  --field 'title=Flux' \
  --field key=@<(
    sops --decrypt src/flux/secrets.sops.yaml |
      yq read --doc '*' --collect - |
      yq read - '(metadata.name==flux-git).data.identity' |
      base64 --decode |
      ssh-keygen -f /dev/stdin -y
  ) \
  --field 'read_only=false' \
  --silent \
  repos/:owner/:repo/keys
