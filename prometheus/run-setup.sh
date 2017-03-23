#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Setting up prometheus"

if [ ! -f prometheus-1.5.2.linux-amd64.tar.gz ]; then
    echo "Downloading Prometheus files for linux"
    curl -OL# https://github.com/prometheus/prometheus/releases/download/v1.5.2/prometheus-1.5.2.linux-amd64.tar.gz
fi

echo "Creating the docker image"
docker build -q -t mattermost-prometheus:v1 .

echo "Deploying to kuberentes"
kubectl create -f k8s-deployment.yaml

echo -e "Finished setting up prometheus\n"