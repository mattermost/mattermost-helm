#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Cleaning up load test job run"

echo "Removing from kubernetes"
kubectl delete job mattermost-load-test

if [ ! -z $(docker images -q mattermost-load-test:v1) ]; then
    echo "Deleting docker images"
    docker rmi -f mattermost-load-test:v1
fi

echo "Removing config files"
rm -f config.json
rm -f loadtestconfig.json

if [ "$1" == "nuke" ]; then
    echo "Removing downloads"
    rm -f mattermost-load-test.tar.gz
    rm -f mattermost-enterprise-linux-amd64.tar.gz
fi

echo -e "Finished cleaning up load test job run\n"