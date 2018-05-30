FROM golang:latest

ENV PATH="/mattermost-load-test/bin:${PATH}"
ENV PATH="/mattermost/bin:${PATH}"
ARG LOADTEST_BINARY
ARG MM_BINARY

WORKDIR /

RUN apt-get update \
    && apt-get -y install \
      curl \
      jq \
      netcat \
      net-tools \
      iproute \
      dnsutils \
      graphviz

RUN mkdir -p /mattermost/data \
    && curl $MM_BINARY | tar -xvz \
    && rm -rf /mattermost/config/config.json

RUN mkdir -p /mattermost-load-test \
	&& curl $LOADTEST_BINARY | tar -xvz \
	&& rm -f /mattermost-load-test/loadtestconfig.json

WORKDIR /mattermost-load-test
CMD ["tail", "-f", "/dev/null"]
