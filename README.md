Mattermost Kubernetes 
==========================

# This is an experimental work in progress

#### XXX TODO FIX ME - Need to document setup process

This projects uses Kubernetes and Helm

1. Modify values.yaml
2. run `make` to build the helm package
3. run `make install` to install the helm package

Some helpful commands

`kubectl proxy` then visit http://localhost:8001/ui

`helm ls`

`helm delete NAME`