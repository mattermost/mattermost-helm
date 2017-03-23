#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Cleaning up volumes"

echo "Removing from kubernetes"

if [ "$1" == "nuke" ]; then
    kubectl delete pvc -l app=mattermost
	kubectl delete pv local-pv-1 local-pv-2
fi

echo -e "Finished cleaning up volumes\n"