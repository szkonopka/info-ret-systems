#!/bin/sh

# install elasticsearch, logstash and kibana from elastic stack
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

sudo apt-get update && 
sudo apt-get install elasticsearch && 
sudo apt-get install kibana &&
sudo apt-get install logstash

# configure to start automatically with system boot
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo /bin/systemctl enable kibana.service

export IRS_ELASTIC_PROJECT_DIR=`pwd`