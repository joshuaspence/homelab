#===============================================================================
# Macros
#===============================================================================
FLUXCTL = fluxctl --k8s-fwd-ns flux

#===============================================================================
# Targets
#===============================================================================
.PHONY: all
all: lint validate

.PHONY: bootstrap
bootstrap:
	helm repo add fluxcd https://charts.fluxcd.io
	kubectl apply bootstrap/namespace.yaml
	kubectl apply --filename bootstrap/flux/flux-release-values.yaml
	helm upgrade --install flux --namespace flux --values <(kubectl get configmap flux-release-values -o json | jq -r '.data."values.yaml"') fluxcd/flux
	kubectl apply --filename bootstrap/helm-operator/helm-operator-release-values.yaml
	helm upgrade --install helm-operator --namespace flux --values <(kubectl get configmap helm-operator-release-values -o json | jq -r '.data."values.yaml"') fluxcd/helm-operator

.PHONY: dev
dev:
	minikube status >/dev/null || minikube start

.PHONY: lint
lint: $(wildcard **/*.yaml) .yamllint
	yamllint --strict $^

.PHONY: ssh-public-key
ssh-public-key:
	$(FLUXCTL) identity

.PHONY: sync
sync:
	$(FLUXCTL) sync

.PHONY: validate
validate:
	kubeval --directories . --ignored-filename-patterns '(kustomization|patch)\.yaml$$' --strict
