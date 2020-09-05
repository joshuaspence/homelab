#!/usr/bin/env bats

load "$(npm root --global)/bats-assert/load.bash"
load "$(npm root --global)/bats-support/load.bash"

function test_certificate() {
  run kubectl get --namespace "${1}" --output 'jsonpath={.status.revision}' "certificate/${2}"
  assert_success
  assert_output
}

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
}

function test_pvc() {
  run kubectl get --namespace "${1}" --output 'jsonpath={.status.phase}' "persistentvolumeclaim/${2}"
  assert_success
  assert_output Bound
}

@test 'cert-manager' {
  test_helmrelease cert-manager cert-manager
}

@test 'external-dns' {
  test_helmrelease kube-system external-dns
}

@test 'flux' {
  test_helmrelease flux flux
}

@test 'helm-operator' {
  test_helmrelease flux helm-operator
}

@test 'home-assistant' {
  test_helmrelease default home-assistant
  test_ingress default home-assistant
  test_certificate default home-assistant-tls
  test_pvc default home-assistant
}

@test 'kubernetes-dashboard' {
  test_helmrelease default kubernetes-dashboard
  test_ingress default kubernetes-dashboard
  test_certificate default kubernetes-dashboard-tls
}

@test 'metallb' {
  test_helmrelease kube-system metallb
}

@test 'nginx-ingress' {
  test_helmrelease kube-system nginx-ingress
}

@test 'prometheus-operator' {
  test_helmrelease monitoring prometheus-operator
  test_ingress monitoring prometheus-operator-alertmanager
  test_certificate monitoring alertmanager-tls
  test_ingress monitoring prometheus-operator-grafana
  test_certificate monitoring grafana-tls
  test_ingress monitoring prometheus-operator-prometheus
  test_certificate monitoring prometheus-tls
  test_ingress monitoring prometheus-operator-thanos-gateway
  test_certificate monitoring thanos-tls
}
