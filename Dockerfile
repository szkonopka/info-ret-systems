FROM ubuntu:18.04
COPY . /app

RUN cd /app/data && \
    bash ./download-pl-wiki-20200301-dumps.sh && \
    cd /app && \
    bash ./elasticsearch/init-elastic-env.sh && \
    cd ./elasticsearch && \ 
    cp -r elasticsearch.yml /etc/elasticsearch/elasticsearch.yml && \
    bash ./logstash-config-reset.sh

ENTRYPOINT cd /app && ./elasticsearch/logstash-load.sh
