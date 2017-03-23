#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Cleaning up first job run"

echo "Removing from kubernetes"
kubectl delete job mattermost-first-run-job
rm -f grafana-dashboard.json
rm -f grafana-dashboard.json-e

if [ ! -z $(docker images -q mattermost-first-run-job:v1) ]; then
    echo "Deleting docker images"
    docker rmi -f mattermost-first-run-job:v1
fi

echo -e "Finished cleaning up first job run\n"