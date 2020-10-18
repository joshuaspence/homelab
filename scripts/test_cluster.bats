#!/usr/bin/env bats

load "$(npm root --global)/bats-assert/load.bash"
load "$(npm root --global)/bats-support/load.bash"

function test_helmrelease() {
  run kubectl get --namespace "${1}" --output 'jsonpath={.status.phase}' "helmrelease/${2}"
  assert_success
  assert_output Succeeded

  run kubectl get --namespace "${1}" --output 'jsonpath={.status.releaseStatus}' "helmrelease/${2}"
  assert_success
  assert_output deployed

  run helm test --namespace "${1}" "${2}"
  assert_success
}

function test_ingress() {
  run kubectl get --namespace "${1}" --output 'jsonpath={.status.loadBalancer.ingress[*].ip}' "ingress/${2}"
  assert_success
  assert_output

  HOST=$(kubectl get --namespace "${1}" --output 'jsonpath={.spec.rules[*].host}' "ingress/${2}")
  IP=$(kubectl get --namespace "${1}" --output 'jsonpath={.status.loadBalancer.ingress[*].ip}' "ingress/${2}")
  assert_equal "$(dig +short "${HOST}")" "${IP}"

  run curl \
    --cacert <(curl --silent https://letsencrypt.org/certs/fakelerootx1.pem) \
    --head \
    --header "Host: ${HOST}" \
    --no-location \
    --request GET \
    --show-error \
    --silent \
    "https://${HOST}"
  assert_success
}

function test_pvc() {
  run kubectl get --namespace "${1}" --output 'jsonpath={.status.phase}' "persistentvolumeclaim/${2}"
  assert_success
  assert_output Bound
}

@test 'cert-manager' {
  test_helmrelease networking cert-manager
}

@test 'external-dns' {
  test_helmrelease networking external-dns
}

@test 'flux' {
  test_helmrelease flux flux
}

@test 'helm-operator' {
  test_helmrelease flux helm-operator
}

@test 'home-assistant' {
  test_helmrelease default home-assistant
  test_pvc default home-assistant
  test_ingress default home-assistant
}

@test 'metallb' {
  test_helmrelease kube-system metallb
}

@test 'nginx-ingress' {
  test_helmrelease kube-system nginx-ingress
}

@test 'prometheus-operator' {
  test_helmrelease monitoring prometheus
  test_ingress monitoring prometheus-operator-alertmanager
  test_ingress monitoring prometheus-operator-grafana
  test_ingress monitoring prometheus-operator-prometheus
  test_ingress monitoring prometheus-operator-thanos-gateway
}
