#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Setting up nginx"

echo "Creating the docker image"
docker build -q -t mattermost-nginx:v1 .

echo "Deploying to kuberentes"
kubectl create -f k8s-deployment.yaml

echo -e "Finished setting up nginx\n"