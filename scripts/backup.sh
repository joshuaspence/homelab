#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# See https://cert-manager.io/docs/tutorials/backup/.
kubectl get --namespace cert-manager --output yaml secret "$(yq read "src/cert-manager/issuers.yaml" spec.acme.privateKeySecretRef.name)"
kubectl get --all-namespaces --output yaml certificates,certificaterequests
