#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Cleaning up mattermost"

echo "Removing from Kubernetes"
kubectl delete deployment,service mattermost-app

echo "Deleting docker images"
docker rmi -f mattermost-app:v1

echo "Deleting ConfigMaps"
kubectl delete configmap mattermost-config

echo "Removing config files"
rm -f config.json

if [ "$1" == "nuke" ]; then
    echo "Removing downloads"
    rm -f mattermost-enterprise-linux-amd64.tar.gz
fi

echo -e "Finished cleaning up mattermost\n"