.PHONY: all
all: lint validate

.PHONY: bootstrap
bootstrap:
	kubectl apply -k fluxcd
	kubectl -n flux rollout status deployment/flux

.PHONY: dev
dev:
	minikube status >/dev/null || minikube start --kubernetes-version=stable

.PHONY: lint
lint: $(wildcard **/*.yaml) .yamllint
	yamllint --strict $^

.PHONY: validate
validate:
	kubeval --directories . --ignored-filename-patterns '(kustomization|patch)\.yaml$$' --strict
