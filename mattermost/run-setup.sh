#!/bin/bash

cd $(dirname $0)
source ../env.sh

echo "Setting up mattermost"

if [ ! -f mattermost-enterprise-linux-amd64.tar.gz ]; then
    echo "Downloading Mattermost files for linux"
    curl -OL# https://releases.mattermost.com/mattermost-platform/$MM_BUILD/mattermost-enterprise-linux-amd64.tar.gz
fi

tar --strip=2 -zxvf mattermost-enterprise-linux-amd64.tar.gz mattermost/config/config.json

echo "Setting database passwords in config"
DB_PASSWORD=$(<../mysql/db-password.txt)
DataSource="mmuser:$DB_PASSWORD@tcp(mattermost-db:3306)/mattermost?charset=utf8mb4,utf8"
jq -r --arg v "$DataSource" '.SqlSettings.DataSource=$v' config.json > configz.json && mv configz.json config.json

echo "Generating one time salts"
PUBLIC_LINK_SALT=$(openssl rand -base64 32 | tr -dc _A-Z-a-z-0-9)
jq -r --arg v "$PUBLIC_LINK_SALT" '.FileSettings.PublicLinkSalt=$v' config.json > configz.json && mv configz.json config.json
INVITE_SALT=$(openssl rand -base64 32 | tr -dc _A-Z-a-z-0-9)
jq -r --arg v "$INVITE_SALT" '.EmailSettings.InviteSalt=$v' config.json > configz.json && mv configz.json config.json
PASSWORD_RESET_SALT=$(openssl rand -base64 32 | tr -dc _A-Z-a-z-0-9)
jq -r --arg v "$PASSWORD_RESET_SALT" '.EmailSettings.PasswordResetSalt=$v' config.json > configz.json && mv configz.json config.json

echo "Configuring log settings"
jq -r '.LogSettings.EnableConsole=true' config.json > configz.json && mv configz.json config.json
jq -r '.LogSettings.ConsoleLevel="INFO"' config.json > configz.json && mv configz.json config.json

echo "Configuring cluster settings"
jq -r '.ClusterSettings.Enable=true' config.json > configz.json && mv configz.json config.json

echo "Configuring miscellaneous settings"
jq -r '.TeamSettings.MaxUsersPerTeam=50000' config.json > configz.json && mv configz.json config.json
jq -r '.TeamSettings.EnableOpenServer=true' config.json > configz.json && mv configz.json config.json
jq -r '.MetricsSettings.Enable=true' config.json > configz.json && mv configz.json config.json

echo "Creating the docker image"
docker build -q -t mattermost-app:v1 .

echo "Creating the ConfigMaps"
kubectl create configmap mattermost-config --from-file=config.json

echo "Deploying to kuberentes"
kubectl create -f k8s-deployment.yaml

echo -e "Finished setting up mattermost\n"