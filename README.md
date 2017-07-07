Mattermost Kubernetes 
==========================

# This is an experimental work in progress

#### XXX TODO FIX ME - Need to document setup process

This projects uses Kubernetes and Helm

1. Modify values.yaml
2. run `make` to build the helm package
3. run `make install` to install the helm package

Helm repository for latest master of this repository is available, to add:

`helm repo add mattermost https://releases.mattermost.com/helm`

To list options for mattermost-helm:

`helm inspect values mattermost-helm`

Create a yaml file `config.yaml` to overide any defaults you want to change and install using:

`helm install -f config.yaml`

Some helpful commands

`kubectl proxy` then visit http://localhost:8001/ui

`helm ls`

`helm delete NAME`
