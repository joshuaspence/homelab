= Helm Charts =
- [`cert-manager`](https://github.com/onedr0p/k3s-gitops/tree/master/deployments/cert-manager)
- [`descheduler`](https://github.com/onedr0p/k3s-gitops/blob/master/deployments/kube-system/descheduler/descheduler.yaml)
- `home-assistant`
  - https://github.com/onedr0p/k3s-gitops/tree/master/deployments/default/home-assistant
	- https://github.com/blackjid/homelab-gitops/tree/master/default/home-assistant
- [`ingress-monitor-controller`](https://github.com/blackjid/homelab-gitops/tree/master/monitoring/ingress-monitor-controller)
- [`kured`](https://github.com/onedr0p/k3s-gitops/blob/master/deployments/kube-system/kured.yaml)
- `loki`
  - https://github.com/onedr0p/k3s-gitops/tree/master/deployments/logging
	- https://github.com/blackjid/homelab-gitops/tree/master/logs/loki
- [`longhorn`](https://github.com/blackjid/homelab-gitops/tree/master/longhorn-system)
- `metallb`
  - https://github.com/onedr0p/k3s-gitops/blob/master/deployments/kube-system/metallb.yaml
	- https://github.com/blackjid/homelab-gitops/tree/master/kube-system/metallb
- [`metrics-server`](https://github.com/onedr0p/k3s-gitops/blob/master/deployments/kube-system/metrics-server.yaml)
- `nfs-client-provisioner`
  - https://github.com/onedr0p/k3s-gitops/blob/master/deployments/kube-system/nfs-client-provisioner.yaml
	- https://github.com/blackjid/homelab-gitops/tree/master/kube-system/nfs-client-provisioner
- [`nfs-pv`](https://github.com/blackjid/homelab-gitops/tree/master/kube-system/nfs-pv)
- `nginx-ingress`
  - https://github.com/onedr0p/k3s-gitops/blob/master/deployments/kube-system/nginx-ingress.yaml
	- https://github.com/blackjid/homelab-gitops/blob/master/kube-system/nginx/nginx-helm-release.yaml
- `node-feature-discovery`
  - https://github.com/onedr0p/k3s-gitops/blob/master/deployments/kube-system/node-feature-discovery/node-feature-discovery.yaml
	- https://github.com/blackjid/homelab-gitops/tree/master/kube-system/node-feature-discovery
- [`oauth2-proxy`](https://github.com/blackjid/homelab-gitops/tree/master/kube-system/oauth2-proxy)
- `prometheus-operator`
  - https://github.com/onedr0p/k3s-gitops/tree/master/deployments/monitoring/prometheus-operator
	- https://github.com/blackjid/homelab-gitops/tree/master/monitoring/prometheus-operator
- [`rook-ceph`](https://github.com/onedr0p/k3s-gitops/tree/master/deployments/rook-ceph)
- `sealed-secrets`
  - https://github.com/onedr0p/k3s-gitops/blob/master/deployments/kube-system/sealed-secrets.yaml)
- [`uptimerobot-heartbeat`](https://github.com/onedr0p/k3s-gitops/blob/master/deployments/monitoring/uptimerobot-heartbeat.yaml)
- [Velero](https://github.com/onedr0p/k3s-gitops/tree/master/deployments/velero)

= Helm Settings =
See [`HelmRelease` Custom Resource](https://github.com/fluxcd/helm-operator/blob/master/docs/references/helmrelease-custom-resource.md).

- `wait`
- `rollback`
- `test`
