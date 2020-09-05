#!/usr/bin/env bats

function assert_helmrelease() {
  run kubectl get --namespace "${1}" --output jsonpath={.status.phase} "helmrelease/${2}"
  [[ $status -eq 0 ]]
  [[ $output = 'Succeeded' ]]

  run kubectl get --namespace "${1}" --output jsonpath={.status.releaseStatus} "helmrelease/${2}"
  [[ $status -eq 0 ]]
  [[ $output = 'deployed' ]]

  run helm test --namespace "${1}" "${2}"
  [[ $status -eq 0 ]]
}

@test 'cert-manager' {
  assert_helmrelease cert-manager cert-manager
}

@test 'external-dns' {
  assert_helmrelease kube-system external-dns
}

@test 'flux' {
  assert_helmrelease flux flux
}

@test 'helm-operator' {
  assert_helmrelease flux helm-operator
}

@test 'home-assistant' {
  assert_helmrelease default home-assistant
}

@test 'kubernetes-dashboard' {
  assert_helmrelease default kubernetes-dashboard
}

@test 'metallb' {
  assert_helmrelease kube-system metallb
}

@test 'nginx-ingress' {
  assert_helmrelease kube-system nginx-ingress
}

@test 'prometheus-operator' {
  assert_helmrelease monitoring prometheus-operator
}
