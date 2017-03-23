#!/bin/bash

cd $(dirname $0)
source ./env.sh

if [ $USING_MINIKUBE ]; then
	minikube service mattermost-grafana
	minikube service mattermost-proxy
fi