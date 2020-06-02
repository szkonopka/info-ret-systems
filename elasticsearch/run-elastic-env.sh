# configure to start automatically with system boot
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl enable kibana.service

export IRS_ELASTIC_PROJECT_DIR=`pwd`
