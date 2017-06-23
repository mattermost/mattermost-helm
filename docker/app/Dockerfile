FROM ubuntu:16.04

ENV PATH="/mattermost/bin:${PATH}"
ARG MM_BINARY

RUN apt-get update \
    && apt-get -y install \
      curl \
      jq \
      netcat \
      net-tools \
      iproute \
      dnsutils

# Prepare Mattermost
RUN mkdir -p /mattermost/data \
    && curl $MM_BINARY | tar -xvz \
    && rm -rf /mattermost/config/config.json

EXPOSE 8065
EXPOSE 8067
EXPOSE 8074
EXPOSE 8075

WORKDIR /mattermost/bin
CMD ["platform"]