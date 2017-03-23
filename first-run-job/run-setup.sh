#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Setting up first job run"

echo "Creating dashboard templates"
cp grafana-dashboard.json.original grafana-dashboard.json
echo '{ "dashboard": ' | cat - grafana-dashboard.json > temp && mv temp grafana-dashboard.json
echo ',"overwrite": true } ' >> grafana-dashboard.json
sed -i'' -e 's|${DS_MATTERMOST}|mattermost-prometheus|g' grafana-dashboard.json
sed -i'' -e 's|label_values(job)|label_values(kubernetes_pod_name)|g' grafana-dashboard.json
sed -i'' -e 's|job=~|kubernetes_pod_name=~|g' grafana-dashboard.json
sed -i'' -e 's|{{job}}|{{kubernetes_pod_name}}|g' grafana-dashboard.json

echo "Creating the docker image"
docker build -q -t mattermost-first-run-job:v1 .

echo "Deploying to kuberentes"
kubectl create -f k8s-deployment.yaml

echo -e "Finished setting up first job run\n"