#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Setting up volumes"

echo "Deploying to kuberentes"
kubectl create -f k8s-deployment.yaml

echo -e "Finished setting up volumes\n"