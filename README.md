# Homelab Kubernetes Cluster

My homelab Kubernetes cluster, automated with [Flux](https://fluxcd.io) and
inspired by [billimek/k8s-gitops](https://github.com/billimek/k8s-gitops).

## Setup

I am currently using a local Kubernetes cluster for development purposes, which
I am managing using [`kind`](https://kind.sigs.k8s.io). Eventually I am deploy
onto a cluster of [Raspberry Pis](https://github.com/joshuaspence/raspberry_pi).

Bootstrapping the cluster should be as simple as running
[`scripts/bootstrap.sh`](scripts/bootstrap.sh).

## Secrets

Secrets are encrypted with [SOPS](https://github.com/mozilla/sops) and committed
to this repository in `*.sops.yaml` files.
