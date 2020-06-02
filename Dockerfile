FROM openjdk:11
COPY . /app

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y gnupg2

RUN cd /app/data && \
    bash ./download-pl-wiki-20200301-dump.sh

RUN cd /app && \
    bash ./elasticsearch/init-elastic-env.sh
RUN cd app/elasticsearch && \ 
    cp -r elasticsearch.yml /etc/elasticsearch/elasticsearch.yml && \
    bash ./logstash-config-reset.sh

FROM node:12.7-alpine AS build
WORKDIR /usr/src/app
COPY ./app/package.json ./
RUN npm install
COPY ./app .
RUN npm run build --prod

FROM nginx:1.17.1-alpine
COPY --from=build /usr/src/app/dist/info-ret-systems-app /usr/share/nginx/html

ENTRYPOINT cd /app && ./elasticsearch/run-elastic-env.sh && ./elasticsearch/logstash-load.sh
