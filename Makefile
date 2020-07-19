.PHONY: all
all: lint

.PHONY: lint
lint:
	yamllint --strict .
