#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Cleaning up nginx"

echo "Removing from Kubernetes"
kubectl delete deployment,service mattermost-proxy

echo "Deleting docker images"
docker rmi -f mattermost-nginx:v1

echo -e "Finished cleaning up nginx\n"