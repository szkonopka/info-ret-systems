#!/bin/bash

curl -XDELETE "localhost:9200/plwiki-20200301"

EXCH_STRING="FILE_TO_LOAD_VAR"
DATA_DIR="./data"
STATS_DIR="./stats"

declare -a plwikifiles=(
    "plwiki-20200301-articles-1.xml"
    "plwiki-20200301-articles-2.xml"
    "plwiki-20200301-articles-3.xml"
    "plwiki-20200301-articles-4.xml"
    "plwiki-20200301-articles-5.xml"
    "plwiki-20200301-articles-6.xml"
    "plwiki-20200301-articles-7.xml"
)

cd ../data 
ABS_DATA_DIR=$(pwd)
cd -

SIZE_ACC=0

for FILE in ${plwikifiles[@]}
do
    FILE_PATH="${ABS_DATA_DIR}/${FILE}"
    sed -i "s@${EXCH_STRING}@${FILE_PATH}@g" ./xml-plwiki.conf
    /usr/share/logstash/bin/logstash -f ./xml-plwiki.conf
    FILE_SIZE=$(ls -l --b=M ${FILE_PATH}| cut -d " " -f5 | cut -d "M" -f 1)
    SIZE_ACC=$[SIZE_ACC+FILE_SIZE]
    curl -XGET "localhost:9200/plwiki-20200301/_stats" > "${STATS_DIR}/${SIZE_ACC}M.json"
    sed -i "s@${FILE_PATH}@${EXCH_STRING}@g" ./xml-plwiki.conf
done