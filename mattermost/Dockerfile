FROM ubuntu:16.04

ENV PATH="/mattermost/bin:${PATH}"

COPY mattermost-enterprise-linux-amd64.tar.gz /

RUN tar -zxf mattermost-enterprise-linux-amd64.tar.gz

RUN rm mattermost-enterprise-linux-amd64.tar.gz
RUN rm /mattermost/config/config.json

EXPOSE 8065
EXPOSE 8067
EXPOSE 8075

WORKDIR /mattermost/bin
CMD ["platform"]
