PWD := ${CURDIR}
ADDITIONAL_BUILD_ARGUMENTS?=""

PKG		:= metacontroller
API_GROUPS := metacontroller/v1alpha1

CURL_RETRIES=3

BIN_DIR := bin
TOOLS_DIR := hack/tools
TOOLS_BIN_DIR := $(abspath $(TOOLS_DIR)/$(BIN_DIR))

export PATH := $(abspath $(TOOLS_BIN_DIR)):$(PATH)
# Active module mode, as we use go modules to manage dependencies
export GO111MODULE=on

HELM_VER := v3.8.1
HELM_BIN := helm
HELM := $(TOOLS_BIN_DIR)/$(HELM_BIN)-$(HELM_VER)

CHART_DIR := charts/global-owner
RELEASE_DIR ?= out
CHART_PACKAGE_DIR ?= $(RELEASE_DIR)/package

CODE_GENERATOR_VERSION="v0.24.3"

$(HELM): ## Put helm into tools folder.
	mkdir -p $(TOOLS_BIN_DIR)
	rm -f "$(TOOLS_BIN_DIR)/$(HELM_BIN)*"
	curl --retry $(CURL_RETRIES) -fsSL -o $(TOOLS_BIN_DIR)/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	chmod 700 $(TOOLS_BIN_DIR)/get_helm.sh
	USE_SUDO=false HELM_INSTALL_DIR=$(TOOLS_BIN_DIR) DESIRED_VERSION=$(HELM_VER) BINARY_NAME=$(HELM_BIN)-$(HELM_VER) $(TOOLS_BIN_DIR)/get_helm.sh
	ln -sf $(HELM) $(TOOLS_BIN_DIR)/$(HELM_BIN)
	rm -f $(TOOLS_BIN_DIR)/get_helm.sh


## --------------------------------------
## Release
## --------------------------------------


RELEASE_TAG ?= $(shell git describe --abbrev=0 2>/dev/null || echo "0.1.0")

$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)/

$(CHART_PACKAGE_DIR):
	mkdir -p $(CHART_PACKAGE_DIR)

all: generate-modules generate-crds

.PHONY: release-chart
release-chart: $(HELM) generate-crds $(RELEASE_DIR) $(CHART_PACKAGE_DIR) ## Builds the chart to publish with a release
	$(HELM) package --dependency-update $(CHART_DIR) --app-version=$(RELEASE_TAG) --version=$(RELEASE_TAG) --destination=$(CHART_PACKAGE_DIR)

.PHONY: generate-crds
generate-crds:
	@echo "+ Generating crds"
	GOBIN=$(TOOLS_BIN_DIR) go install sigs.k8s.io/controller-tools/cmd/controller-gen@latest
	$(TOOLS_BIN_DIR)/controller-gen +crd +paths="./api/..." +output:crd:stdout > v1/crdv1.yaml

.PHONY: generate-modules
generate-modules: ## Run go mod tidy to ensure modules are up to date
	go mod tidy