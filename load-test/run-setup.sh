#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Setting up load test job run"

if [ ! -f mattermost-load-test.tar.gz ]; then
    echo "Downloading Mattermost load test files for linux"
    curl -OL# https://releases.mattermost.com/mattermost-load-test/mattermost-load-test.tar.gz
fi

if [ ! -f mattermost-enterprise-linux-amd64.tar.gz ]; then
    echo "Downloading Mattermost cli files for linux"
    cp ../mattermost/mattermost-enterprise-linux-amd64.tar.gz .
fi

if [ ! -f config.json ]; then
    echo "Downloading Mattermost config file for linux"
    cp ../mattermost/config.json .
fi

tar --strip=1 -zxvf mattermost-load-test.tar.gz mattermost-load-test/loadtestconfig.json

echo "Setting config file"
jq -r --arg v "http://mattermost-proxy" '.ConnectionConfiguration.ServerURL=$v' loadtestconfig.json > loadtestconfigz.json && mv loadtestconfigz.json loadtestconfig.json
jq -r --arg v "ws://mattermost-proxy" '.ConnectionConfiguration.WebsocketURL=$v' loadtestconfig.json > loadtestconfigz.json && mv loadtestconfigz.json loadtestconfig.json

jq -r '.UserCreationConfiguration.Num=20' loadtestconfig.json > loadtestconfigz.json && mv loadtestconfigz.json loadtestconfig.json
jq -r '.UserEntitiesConfiguration.LastEntityNumber=20' loadtestconfig.json > loadtestconfigz.json && mv loadtestconfigz.json loadtestconfig.json
jq -r '.UserEntitiesConfiguration.EntityRampupDistanceMilliseconds=100' loadtestconfig.json > loadtestconfigz.json && mv loadtestconfigz.json loadtestconfig.json
jq -r '.UserEntityPosterConfiguration.PostingFrequencySeconds=1' loadtestconfig.json > loadtestconfigz.json && mv loadtestconfigz.json loadtestconfig.json

echo "Creating the docker image"
docker build -q -t mattermost-load-test:v1 .

echo "Deploying to kuberentes"
kubectl create -f k8s-deployment.yaml

echo -e "Finished setting up load test job run\n"