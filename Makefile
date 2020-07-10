.PHONY: all
all: lint

.PHONY: dev
dev:
	minikube status >/dev/null || minikube start --kubernetes-version=stable

.PHONY: lint
lint: $(wildcard **/*.yaml) $(wildcard **/*.yml) .yamllint
	yamllint --strict $^
