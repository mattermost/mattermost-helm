DOCKER := $(shell which docker)
DOCKER_OPTS += --rm -u $$(id -u):$$(id -g)
CLUSTER_NAME ?= mattermost-helm-test

DOCKER_IMAGE_SHELLCHECK ?= koalaman/shellcheck:v0.8.0@sha256:4c4427336d2b4bdb054a1e97396fa2e9ca0c329a1f43f831b99bcaae4ac24fcd
# Official image of chart-testing[https://github.com/helm/chart-testing].
# Contains chart-testing cli,  helm and kubectl.
DOCKER_IMAGE_CT ?= quay.io/helmpack/chart-testing:v3.7.0@sha256:2f87e56a0cebc6d9bb78d51cb6adac97858afb0887cac4d65f7f8c6a16054568

# Official image of chart-releaser[https://github.com/helm/chart-releaser].
# Contains chart-releaser cli.
DOCKER_IMAGE_CR ?= quay.io/helmpack/chart-releaser:v1.4.0@sha256:f9e6b06a1d60bcd94a2a6a4988a59233936239347c69b4ab2d99916ffc848a5b

# Define all shell scripts here, the list will be provided to lint target as arguments.
VERIFY_SCRIPTS += /src/tests/e2e-kind.sh /src/scripts/release.sh

CT_CONFIG ?= tests/ct.yaml
KIND_CONFIG ?= tests/kind-config.yaml
CLUSTER_NAME ?= mattermost-helm-test

GIT_USER ?= mattermod
GIT_EMAIL ?= dev-ops@mattermost.com

.PHONY: lint
lint: lint-scripts lint-charts ## Lint helm charts and shell scripts

 .PHONY: lint-charts
lint-charts: ## Validate helm charts
	$(DOCKER) run \
		${DOCKER_OPTS} \
		-v $(PWD):/src \
		-w /src \
		--entrypoint '/bin/bash' \
		-e XDG_DATA_HOME="/src/.helm/data" \
		-e XDG_CONFIG_HOME="/src/.helm/config" \
		-e XDG_CACHE_HOME="/src/.helm/cache" \
		${DOCKER_IMAGE_CT} \
		-c \
		"ls >/dev/null && ct lint --config tests/ct.yaml"

.PHONY: lint-scripts
lint-scripts: ## Validate shell scripts
	$(DOCKER) run \
		${DOCKER_OPTS} \
		-v $(PWD):/src \
		-w /src \
		${DOCKER_IMAGE_SHELLCHECK} \
		$(VERIFY_SCRIPTS)
.PHONY: release
release: ## Release Changed Helm Charts
	DOCKER_IMAGE_CT="$(DOCKER_IMAGE_CT)" \
	DOCKER_IMAGE_CR="${DOCKER_IMAGE_CR}" \
	GIT_USER="${GIT_USER}" \
	GIT_EMAIL="${GIT_EMAIL}" \
	 	scripts/release.sh


.PHONY: test
test: ## Execute e2e tests on changed charts
	 DOCKER_IMAGE_CT="$(DOCKER_IMAGE_CT)" \
	 CLUSTER_NAME="$(CLUSTER_NAME)" \
	 CT_CONFIG="$(CT_CONFIG)" \
	 KIND_CONFIG="$(KIND_CONFIG)" \
	 	tests/e2e-kind.sh

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


