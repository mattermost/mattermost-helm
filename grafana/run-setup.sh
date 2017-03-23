#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Setting up grafana"

echo "Creating the docker image"
docker build -q -t mattermost-grafana:v1 .

echo "Deploying to kuberentes"
kubectl create -f k8s-deployment.yaml
minikube service mattermost-grafana --url

echo -e "Finished setting up grafana\n"