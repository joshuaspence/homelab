package main

import data.kubernetes

required_annotations {
  input.metadata.annotations["fluxcd.io/automated"]
}

deny[msg] {
  kubernetes.is_helmrelease
  not required_annotations
  msg = sprintf("%s %s is missing required annotations", [input.kind, input.metadata.name])
}
