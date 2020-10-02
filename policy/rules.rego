package main

import data.kubernetes

kind = input.kind
name = input.metadata.name

required_annotations {
  input.metadata.annotations["fluxcd.io/automated"]
}

warn[msg] {
  kubernetes.is_helmrelease
  not required_annotations
  msg = sprintf("%s %s is missing required annotations", [kind, name])
}

warn[msg] {
  kubernetes.is_helmrelease
  not input.metadata.namespace
  msg = sprintf("%s %s is missing namespace", [kind, name])
}

is_valid_chart {
  chart := input.spec.chart
  chart.name
  chart.repository
  chart.version
}

deny[msg] {
  kubernetes.is_helmrelease
  not is_valid_chart
  msg = sprintf("%s %s is missing chart", [kind, name])
}

warn[msg] {
  kubernetes.is_helmrelease
  not input.spec.releaseName
  msg = sprintf("%s %s is missing releaseName", [kind, name])
}

fluxcdio_automated_valid {
  some i
  values := ["true", "false"]
  input.metadata.annotations["fluxcd.io/automated"] = values[i]
}

deny[msg] {
  kubernetes.is_helmrelease
  not fluxcdio_automated_valid
  msg = "Invalid value for fluxcd.io/automated annotation"
}

fluxcdio_locked_valid {
  some i
  values := ["true", "false"]
  input.metadata.annotations["fluxcd.io/locked"] = values[i]
}

deny[msg] {
  kubernetes.is_helmrelease
  input.metadata.annotations["fluxcd.io/locked"]
  not fluxcdio_locked_valid
  msg = "Invalid value for fluxcd.io/locked annotation"
}
