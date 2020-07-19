.PHONY: all
all: lint validate

.PHONY: lint
lint:
	yamllint --strict .

.PHONY: validate
validate:
	kubeval --directories . --ignore-missing-schemas --strict
