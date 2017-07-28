.PHONY: install clean package

DIST_ROOT=dist
KUBE_INSTALL := $(shell command -v kubectl 2> /dev/null)
HELM_INSTALL := $(shell command -v helm 2> /dev/null)

SUB_CHARTS := $(shell ls mattermost-helm/charts)

all: package

check:
ifndef KUBE_INSTALL
    $(error "kubectl is not available please install from https://kubernetes.io/")
endif
ifndef HELM_INSTALL
    $(error "helm is not available please install from https://github.com/kubernetes/helm")
endif

.init:
	helm init --client-only
	touch $@
	
package: check .init
	mkdir -p dist
	rm -f mattermost-helm/charts/*.tgz
	helm package mattermost-helm/charts/* -d mattermost-helm/charts
	helm package mattermost-helm -d $(DIST_ROOT)

clean:
	rm -rf $(DIST_ROOT)
	rm -f mattermost-helm/charts/*.tgz

install: check
	helm install dist/mattermost-helm*.*
