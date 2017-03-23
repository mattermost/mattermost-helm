#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Cleaning up prometheus"

echo "Removing from Kubernetes"
kubectl delete deployment,service mattermost-prometheus
kubectl delete pvc prometheus-pv-claim

if [ ! -z $(docker images -q mattermost-prometheus:v1) ]; then
    echo "Deleting docker images"
    docker rmi -f mattermost-prometheus:v1
fi

if [ "$1" == "nuke" ]; then
    echo "Removing downloads"
    rm -rf prometheus-1.5.2.linux-amd64.tar.gz
fi

echo -e "Finished cleaning up prometheus\n"