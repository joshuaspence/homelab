#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Delete existing deployment keys.
gh api repos/:owner/:repo/keys | jq '.[] | .id' | xargs --replace gh api repos/:owner/:repo/keys/{} --method DELETE

# Create a new deployment key.
gh api repos/:owner/:repo/keys --field 'title=Flux' --field key=@<(sops --decrypt src/flux/secrets.sops.yaml | yq read --doc '*' --collect - | yq read - '(metadata.name==flux-git).data.identity' | base64 --decode | ssh-keygen -f /dev/stdin -y) --field 'read_only=false' >/dev/null
