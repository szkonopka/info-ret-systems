#!/bin/sh

# install elasticsearch, logstash and kibana from elastic stack
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list

apt-get update && 
apt-get install elasticsearch && 
apt-get install kibana &&
apt-get install logstash

# configure to start automatically with system boot
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl enable kibana.service

export IRS_ELASTIC_PROJECT_DIR=`pwd`