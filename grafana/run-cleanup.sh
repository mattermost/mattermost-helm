#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Cleaning up grafana"

echo "Removing from kubernetes"
kubectl delete deployment,service mattermost-grafana
kubectl delete pvc grafana-pv-claim

if [ ! -z $(docker images -q mattermost-grafana:v1) ]; then
    echo "Deleting docker images"
    docker rmi -f mattermost-grafana:v1
fi

echo -e "Finished cleaning up grafana\n"