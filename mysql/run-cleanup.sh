#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Cleaning up mysql"

echo "Removing from kubernetes"
kubectl delete secret mattermost-db-root-password
kubectl delete secret mattermost-db-password
kubectl delete deployment,service mattermost-db
kubectl delete pvc mattermost-db-pv-claim

echo "Deleting docker images"
docker rmi -f mattermost-db:v1

if [ "$1" == "nuke" ]; then
    echo "Removing db password files"
    rm -f db-password.txt
    rm -f db-root-password.txt
fi

echo -e "Finished cleaning up mysql\n"