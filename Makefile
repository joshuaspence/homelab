.PHONY: all
all: lint validate

.PHONY: dev
dev:
	minikube status >/dev/null || minikube start
	kubectl apply -k fluxcd
	kubectl --namespace flux rollout status deployment/flux

.PHONY: lint
lint: $(wildcard **/*.yaml) .yamllint
	yamllint --strict $^

.PHONY: validate
validate:
	kubeval --directories . --ignored-filename-patterns '(kustomization|patch)\.yaml$$' --strict
