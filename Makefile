#===============================================================================
# Macros
#===============================================================================
FLUXCTL = fluxctl --k8s-fwd-ns flux

#===============================================================================
# Targets
#===============================================================================
.PHONY: all
all: lint validate

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
