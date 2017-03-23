#!/bin/bash

./first-run-job/run-cleanup.sh "$1"
./grafana/run-cleanup.sh "$1"
./prometheus/run-cleanup.sh "$1"
./nginx/run-cleanup.sh "$1"
./mattermost/run-cleanup.sh "$1"
./mysql/run-cleanup.sh "$1"
./volumes/run-cleanup.sh "$1"