#!/bin/bash

curl -XDELETE "localhost:9200/plwiki-20200301"

EXCH_STRING="FILE_TO_LOAD_VAR"
DATA_DIR="./data"
STATS_DIR="./stats"
SINCE_DB_PATH="/home/samzon/current-position"
CHECK_ONGOING=1

declare -a plwikifiles=(
    "plwiki-20200301-articles-1.xml"
    "plwiki-20200301-articles-2.xml"
    "plwiki-20200301-articles-3.xml"
    "plwiki-20200301-articles-4.xml"
    "plwiki-20200301-articles-5.xml"
    "plwiki-20200301-articles-6.xml"
    "plwiki-20200301-articles-7.xml"
)

kill_logstash_instance() {
    CHECK_ONGOING=0
}

check_current_file_status() {
    cat $SINCE_DB_PATH
    echo "Read bytes = $1 BYTES / $2 BYTES [TARGET]"
    READ_MB=[$1/1000]
    TARGET_MB=[$2/1000]
    if [ $READ_MB = $TARGET_MB ]; then
        echo "TARGET achieved!"
        kill_logstash_instance
    else
        echo "TARGET not achieved, still processing..."
    fi
}

check_interval() {
    while [ $CHECK_ONGOING -le 1 ]
    do
        sleep 20
        READ_BYTES=$(cat ${SINCE_DB_PATH}| cut -d " " -f4)
        test -f /home/samzon/current-position && check_current_file_status $READ_BYTES $1 
    done
}

reindex_and_measure() {
    curl -X POST "localhost:9200/_reindex?pretty" -H 'Content-Type: application/json' -d'
        {
            "source": {
                "index": "plwiki-20200301"
            },
            "dest": {
                "index": "plwiki-20200301-current"
            }
        }
    '

    curl -XPUT "localhost:9200"
    curl -XGET "localhost:9200/plwiki-20200301-current/_stats" > "${STATS_DIR}/$1M.json"
    curl -XDELETE "localhost:9200/plwiki-20200301-current"
}

cd ../data 
ABS_DATA_DIR=$(pwd)
cd -

SIZE_ACC=0

for FILE in ${plwikifiles[@]}
do
    FILE_PATH="${ABS_DATA_DIR}/${FILE}"
    sed -i "s@${EXCH_STRING}@${FILE_PATH}@g" ./xml-plwiki.conf

    FILE_SIZE_M=$(ls -l --b=M ${FILE_PATH}| cut -d " " -f5 | cut -d "M" -f 1)
    FILE_SIZE_B=$(ls -l ${FILE_PATH}| cut -d " " -f5)

    /usr/share/logstash/bin/logstash -f ./xml-plwiki.conf & check_interval $FILE_SIZE_B
    wait

    SIZE_ACC=$[SIZE_ACC+FILE_SIZE]
    reindex_and_measure $SIZE_ACC
    
    sed -i "s@${FILE_PATH}@${EXCH_STRING}@g" ./xml-plwiki.conf
done