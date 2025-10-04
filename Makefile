.DEFAULT_GOAL:=help

BUILD_DIR:=build
CHART_NAME?=hoppscotch
CHART_NAMESPACE?=default
CHART_VALUES?=charts/${CHART_NAME}/ci/default-values.yaml
CLUSTER_NAME?=helm-charts
TEST_E2E_DIR:=test/e2e

.PHONY: clean
clean: ## Clean up temporary resources
	@echo "Cleaning up temporary resources"
	rm -rf ${BUILD_DIR}
	rm -rf .cr-release-packages

.PHONY: fmt
fmt: fmt-markdown fmt-shell fmt-yaml ## Check all files formatting

.PHONY: fmt-fix
fmt-fix: fmt-markdown-fix fmt-shell-fix fmt-yaml-fix ## Fix all files formatting

.PHONY: fmt-markdown
fmt-markdown: ## Check Markdown files formatting
	@echo "Checking Markdown files formatting"
	prettier -c "**/*.md"

.PHONY: fmt-markdown-fix
fmt-markdown-fix: ## Fix Markdown files formatting
	@echo "Fixing Markdown files formatting"
	prettier -w "**/*.md"

.PHONY: fmt-shell
fmt-shell: ## Check shell scripts formatting
	@echo "Checking shell scripts formatting"
	shfmt -l -d .

.PHONY: fmt-shell-fix
fmt-shell-fix: ## Fix shell scripts formatting
	@echo "Fixing shell scripts formatting"
	shfmt -l -w .

.PHONY: fmt-yaml
fmt-yaml: ## Check YAML files formatting
	@echo "Checking YAML files formatting"
	prettier -c "**/*.yaml"

.PHONY: fmt-yaml-fix
fmt-yaml-fix: ## Fix YAML files formatting
	@echo "Fixing YAML files formatting"
	prettier -w "**/*.yaml"

.PHONY: helm-deps-update
helm-deps-update: ## Update chart dependencies
	@echo "Updating ${CHART_NAME} chart dependencies"
	helm dependency update charts/${CHART_NAME}

.PHONY: helm-docs
helm-docs: ## Generate Helm docs
	@echo "Generating Helm docs"
	helm-docs --sort-values-order=file
	$(MAKE) fmt-markdown-fix

.PHONY: helm-install
helm-install: kind-create-cluster ## Install chart
	@echo "Installing ${CHART_NAME} chart"
	helm install ${CHART_NAME} charts/${CHART_NAME} -n ${CHART_NAMESPACE} --values=${CHART_VALUES} --create-namespace --wait

.PHONY: helm-package
helm-package: clean ## Package Helm charts
	@echo "Packaging Helm charts"
	cr package charts/${CHART_NAME}

.PHONY: helm-test
helm-test: ## Run chart tests
	@echo "Running ${CHART_NAME} chart tests"
	helm test ${CHART_NAME} --namespace ${CHART_NAMESPACE}

.PHONY: helm-template
helm-template: clean ## Render chart templates
	@echo "Rendering ${CHART_NAME} chart templates"
	@mkdir -p ${BUILD_DIR}
	helm template ${CHART_NAME} charts/${CHART_NAME} > "${BUILD_DIR}/${CHART_NAME}.yaml"

.PHONY: helm-uninstall
helm-uninstall: ## Uninstall chart
	@echo "Uninstalling ${CHART_NAME} chart"
	@if ! helm list -n ${CHART_NAMESPACE} | grep -q ${CHART_NAME}; then \
		echo "Warning: Chart ${CHART_NAME} is not installed"; \
		exit 0; \
	else \
		helm uninstall ${CHART_NAME} -n ${CHART_NAMESPACE}; \
	fi

.PHONY: helm-upgrade
helm-upgrade: ## Upgrade chart
	@echo "Upgrading ${CHART_NAME} chart"
	helm upgrade ${CHART_NAME} charts/${CHART_NAME} -n ${CHART_NAMESPACE} --values=${CHART_VALUES} --wait

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install-deps
install-deps: ## Install dependencies
	@echo "Installing dependencies"
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) install-deps-macos; \
	elif [ "$$(uname)" = "Linux" ]; then \
		$(MAKE) install-deps-linux; \
	else \
		echo "Error: Unsupported operating system: $$(uname)"; \
		exit 1; \
	fi

.PHONY: install-deps-linux
install-deps-linux: ## Install dependencies for Linux
	@echo "Installing dependencies for Linux"
	@if ! command -v go &> /dev/null; then \
		echo "Error: Go is not installed" 1>&2; \
		exit 1; \
	fi
	@if ! command -v npm &> /dev/null; then \
		echo "Error: NPM is not installed" 1>&2; \
		exit 1; \
	fi
	@echo "Installing chart-releaser"
	curl -sLo cr.tar.gz https://github.com/helm/chart-releaser/releases/download/v1.8.1/chart-releaser_1.8.1_linux_amd64.tar.gz && tar -C /usr/local/bin -xzf cr.tar.gz && rm cr.tar.gz
	@echo "Installing chart-testing"
	curl -sLo ct.tar.gz https://github.com/helm/chart-testing/releases/download/v3.13.0/chart-testing_3.13.0_linux_amd64.tar.gz && tar -C /usr/local/bin -xzf ct.tar.gz && rm ct.tar.gz
	@echo "Installing Docker"
	sudo apt -y install docker.io
	@echo "Installing Helm"
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
	@echo "Installing helm-unittest"
	@if ! helm plugin list | grep -q 'unittest'; then \
		helm plugin install https://github.com/helm-unittest/helm-unittest; \
	else \
		echo "Warning: helm-unittest plugin is already installed"; \
	fi
	@echo "Installing helm-docs"
	go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
	@echo "Installing kind"
	go install sigs.k8s.io/kind@latest
	@echo "Installing markdownlint-cli"
	npm install -g markdownlint-cli
	@echo "Installing prettier"
	npm install -g prettier
	@echo "Installing shellcheck"
	sudo apt -y install shellcheck
	@echo "Installing shfmt"
	go install mvdan.cc/sh/v3/cmd/shfmt@latest
	@echo "Installing yamllint"
	sudo apt-get -y install yamllint

.PHONY: install-deps-macos
install-deps-macos: ## Install dependencies for MacOS
	@echo "Installing dependencies for MacOS"
	@if ! command -v brew &> /dev/null; then \
		echo "Error: Homebrew is not installed" 1>&2; \
		exit 1; \
	fi
	brew update
	brew install chart-releaser
	brew install chart-testing
	brew install docker
	brew install helm
	@if ! helm plugin list | grep -q 'unittest'; then \
		helm plugin install https://github.com/helm-unittest/helm-unittest; \
	else \
		echo "Warning: helm-unittest plugin is already installed"; \
	fi
	brew install norwoodj/tap/helm-docs
	brew install kind
	brew install markdownlint-cli
	brew install prettier
	brew install shellcheck
	brew install shfmt
	brew install yamllint

.PHONY: kind-create-cluster
kind-create-cluster: ## Create a kind cluster
	@echo "Creating kind cluster"
	@if kind get clusters | grep -q "${CLUSTER_NAME}"; then \
		echo "Warning: kind cluster ${CLUSTER_NAME} already exists"; \
	else \
		kind create cluster --name=${CLUSTER_NAME} --config=${TEST_E2E_DIR}/kind.yaml; \
		kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml; \
		echo "Waiting for cluster to be ready"; \
		sleep 5; \
		kubectl wait --namespace=ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=60s; \
	fi

.PHONY: kind-delete-cluster
kind-delete-cluster: ## Delete the kind cluster
	@echo "Deleting ${CLUSTER_NAME} kind cluster"
	@if kind get clusters | grep -q "${CLUSTER_NAME}"; then \
		kind delete cluster --name=${CLUSTER_NAME}; \
	else \
		echo "Warning: Kind cluster ${CLUSTER_NAME} does not exist"; \
	fi

.PHONY: lint
lint: lint-helm lint-markdown lint-shell lint-yaml ## Run all linters

.PHONY: lint-helm
lint-helm: ## Lint Helm charts
	@echo "Linting Helm charts"
	ct lint --config=ct.yaml --lint-conf=lintconf.yaml --all

.PHONY: lint-markdown
lint-markdown: ## Lint Markdown files
	@echo "Linting Markdown files"
	markdownlint -d "**/*.md"

.PHONY: lint-shell
lint-shell: ## Lint shell scripts
	@echo "Linting shell scripts"
	find . -type f -name "*.sh" | xargs shellcheck

.PHONY: lint-yaml
lint-yaml: ## Lint YAML files
	@echo "Linting YAML files"
	yamllint .

.PHONY: pre-commit
pre-commit: fmt lint test-unit ## Run pre-commit hooks

.PHONY: test-e2e
test-e2e: ## Run end-to-end tests
	@echo "Running end-to-end tests for ${CHART_NAME} chart"
	${TEST_E2E_DIR}/test-e2e.sh --charts=charts/${CHART_NAME} --debug

.PHONY: test-integration
test-integration: helm-test ## Run integration tests

.PHONY: test-unit
test-unit: ## Run unit tests
	@echo "Running unit tests"
	helm unittest charts/*

.PHONY: test
test: test-unit test-e2e ## Run all tests
