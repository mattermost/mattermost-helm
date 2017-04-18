FROM ubuntu:16.04

ENV PATH="/mattermost/bin:/mattermost-load-test/bin:${PATH}"

COPY mattermost-enterprise-linux-amd64.tar.gz /

RUN tar -zxf mattermost-enterprise-linux-amd64.tar.gz

RUN rm mattermost-enterprise-linux-amd64.tar.gz
RUN rm /mattermost/config/config.json

COPY mattermost-load-test.tar.gz /

RUN tar -zxf mattermost-load-test.tar.gz
COPY loadtestconfig.json /mattermost-load-test/loadtestconfig.json

RUN rm mattermost-load-test.tar.gz

COPY load-test.sh /mattermost-load-test/bin/load-test.sh

WORKDIR /mattermost-load-test/bin
