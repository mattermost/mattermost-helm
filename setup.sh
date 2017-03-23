#!/bin/bash

./volumes/run-setup.sh
./mysql/run-setup.sh
./mattermost/run-setup.sh
./nginx/run-setup.sh
./prometheus/run-setup.sh
./grafana/run-setup.sh
./first-run-job/run-setup.sh

