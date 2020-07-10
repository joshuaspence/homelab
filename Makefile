.PHONY: dev
dev:
	minikube status >/dev/null || minikube start --kubernetes-version=stable
