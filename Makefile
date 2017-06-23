.PHONY: install clean package

DIST_ROOT=dist
KUBE_INSTALL := $(shell command -v kubectl 2> /dev/null)
HELM_INSTALL := $(shell command -v helm 2> /dev/null)

all: package

check:
ifndef KUBE_INSTALL
    $(error "kubectl is not available please install from https://kubernetes.io/")
endif
ifndef HELM_INSTALL
    $(error "helm is not available please install from https://github.com/kubernetes/helm")
endif
	
package: check
	mkdir -p dist
	helm package mattermost-helm -d $(DIST_ROOT)

clean:
	rm -rf $(DIST_ROOT)

install: check
	helm install dist/mattermost-helm*.*