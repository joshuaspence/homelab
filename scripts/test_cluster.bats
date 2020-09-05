#!/usr/bin/env bats

load "$(npm root --global)/bats-assert/load.bash"
load "$(npm root --global)/bats-support/load.bash"

function test_helmrelease() {
  run kubectl get --namespace "${1}" --output jsonpath={.status.phase} "helmrelease/${2}"
  assert_success
  assert_output 'Succeeded'

  run kubectl get --namespace "${1}" --output jsonpath={.status.releaseStatus} "helmrelease/${2}"
  assert_success
  assert_output 'deployed'

  run helm test --namespace "${1}" "${2}"
  assert_success
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
}

@test 'kubernetes-dashboard' {
  test_helmrelease default kubernetes-dashboard
}

@test 'metallb' {
  test_helmrelease kube-system metallb
}

@test 'nginx-ingress' {
  test_helmrelease kube-system nginx-ingress
}

@test 'prometheus-operator' {
  test_helmrelease monitoring prometheus-operator
}

@test 'Ingresses have IP addresses' {
  for RESOURCE in $(kubectl get --all-namespaces --output 'jsonpath={range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}' ingress); do
    IFS=/ read -a RESOURCE -r <<< "${RESOURCE}"
    run kubectl get --namespace "${RESOURCE[0]}" --output jsonpath={.status.loadBalancer.ingress[*].ip} "ingress/${RESOURCE[1]}"
    assert_success
    assert_output
  done
}
