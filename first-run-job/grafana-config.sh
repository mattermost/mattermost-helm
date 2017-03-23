#!/bin/bash

echo "Configuring Grafana for the first time"

GRAFANA_URL=http://mattermost-grafana:3000/api
COOKIEJAR=./cookies.tmp
touch $COOKIEJAR
trap 'unlink ${COOKIEJAR}' EXIT


echo "Setting up the Grafana session"
if ! curl -H 'Content-Type: application/json;charset=UTF-8' \
	--data-binary '{"user":"admin","email":"","password":"admin"}' \
	--cookie-jar "$COOKIEJAR" \
	'http://mattermost-grafana:3000/login' > /dev/null 2>&1 ; then
	echo "Grafana session: Couldn't store cookies at ${COOKIEJAR}"
fi

echo "Checking to see if the datasource already exists"

DB_ALREADY_EXISTS=$(curl --silent --cookie "$COOKIEJAR" "$GRAFANA_URL/datasources" | grep "\"name\":\"mattermost-prometheus\"" | wc -l)

if [ "$DB_ALREADY_EXISTS" == "1" ]; then
	echo "Skipping creation because the datasource already exists"
else
  echo "Creating the grafana datasource"
	curl --cookie "$COOKIEJAR" \
       -X POST \
       --silent \
       -H 'Content-Type: application/json;charset=UTF-8' \
       --data-binary "{\"name\":\"mattermost-prometheus\",\"type\":\"prometheus\",\"url\":\"http://mattermost-prometheus:9090\",\"access\":\"proxy\",\"database\":\"\",\"user\":\"\",\"password\":\"\",\"isDefault\": true }" \
       "$GRAFANA_URL/datasources"
    echo ""
fi

echo "Creating the grafana dashboard"
curl --cookie "$COOKIEJAR" \
   -X POST \
   --silent \
   -H 'Content-Type: application/json;charset=UTF-8' \
   --data-binary @./grafana-dashboard.json \
   "$GRAFANA_URL/dashboards/db"
echo ""

echo -e "Finished configuring Grafana for the first time\n"