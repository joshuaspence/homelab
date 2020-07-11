#===============================================================================
# Macros
#===============================================================================
FLUXCTL = fluxctl --k8s-fwd-ns flux

#===============================================================================
# Targets
#===============================================================================
.PHONY: all
all: lint validate

.PHONY: dev
dev:
	minikube status >/dev/null || minikube start
	kubectl apply -k fluxcd
	kubectl --namespace flux rollout status deployment/flux
	kustomize build helm-operator | kubectl apply --filename -
	kubectl --namespace flux rollout status deployment/helm-operator

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
