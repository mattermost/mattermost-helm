#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Setting up mysql"

echo "Creating the docker image"
docker build -q -t mattermost-db:v1 .

if [ ! -f db-root-password.txt ]; then
	echo "Generating database root password"
	ROOT_DB_PASSWORD=$(openssl rand -base64 12 | tr -dc _A-Z-a-z-0-9)
	echo "$ROOT_DB_PASSWORD" > db-root-password.txt
	tr -d '\n' <db-root-password.txt >.strippedpassword.txt && mv .strippedpassword.txt db-root-password.txt
fi

if [ ! -f db-password.txt ]; then
	echo "Generating database password"
	DB_PASSWORD=$(openssl rand -base64 12 | tr -dc _A-Z-a-z-0-9)
	echo "$DB_PASSWORD" > db-password.txt
	tr -d '\n' <db-password.txt >.strippedpassword.txt && mv .strippedpassword.txt db-password.txt
fi

echo "Deploying to kuberentes"
kubectl create secret generic mattermost-db-root-password --from-file=db-root-password.txt
kubectl create secret generic mattermost-db-password --from-file=db-password.txt
kubectl create -f k8s-deployment.yaml

echo -e "Finished setting up mysql\n"