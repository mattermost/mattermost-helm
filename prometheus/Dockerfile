FROM ubuntu:16.04

ENV PATH="/prometheus:${PATH}"

COPY prometheus-1.5.2.linux-amd64.tar.gz /

RUN tar -zxf prometheus-1.5.2.linux-amd64.tar.gz

RUN rm prometheus-1.5.2.linux-amd64.tar.gz
RUN mv /prometheus-1.5.2.linux-amd64 /prometheus
COPY prometheus.yml /prometheus/prometheus.yml

EXPOSE 9090

WORKDIR /prometheus
CMD ["prometheus"]
