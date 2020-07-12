.PHONY: all
all: lint validate

.PHONY: lint
lint:
	yamllint --strict .

.PHONY: logs-flux
logs-flux:
	kubectl --namespace flux logs --follow deployment/flux

.PHONY: logs-helm
logs-helm:
	kubectl --namespace flux logs --follow deployment/helm-operator

.PHONY: validate
validate:
	kubeval --directories . --ignore-missing-schemas --strict

