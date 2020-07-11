#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

fluxctl install --git-email support@weave.works --git-readonly --git-url https://github.com/joshuaspence/homelab.git --namespace flux | kubectl --filename -
