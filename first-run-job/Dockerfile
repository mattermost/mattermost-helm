FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl

ENV PATH="/first-run-job:${PATH}"

COPY grafana-config.sh /first-run-job/grafana-config.sh
COPY grafana-dashboard.json /first-run-job/grafana-dashboard.json


WORKDIR /first-run-job
