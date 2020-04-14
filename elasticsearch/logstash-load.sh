#!/bin/bash

EXCH_STRING="FILE_TO_LOAD_VAR"
DATA_DIR="./data"
STATS_DIR="./stats"
SINCE_DB_PATH="/home/samzon/current-position"
CHECK_ONGOING=1

./logstash-config-reset.sh
curl -XDELETE "localhost:9200/plwiki-20200301"
rm -rf $SINCE_DB_PATH

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
    echo "Read bytes = $1 B / $2 B [TARGET]"
    READ_MB=$(($1/1000))
    TARGET_MB=$(($2/1000))
    echo "Read kilo bytes = $READ_MB KB / $TARGET_MB KB [TARGET]"

    if [ $READ_MB = $TARGET_MB ]; then
        echo "TARGET achieved!"
        kill_logstash_instance
    else
        echo "TARGET not achieved, still processing..."
    fi
}

file_processed() {
    FILE_NAME=$1

    test $(cat ${SINCE_DB_PATH} | grep $FILE_NAME | cut -d " " -f4)
}

log_progress() {
    TARGET_FILE_SIZE_B=$1
    FILE_NAME=$2

    READ_BYTES=$(cat ${SINCE_DB_PATH} | grep $FILE_NAME | cut -d " " -f4)
    echo "READ_BYTES $READ_BYTES"
    echo "TARGET_FILE_SIZE_B = $TARGET_FILE_SIZE_B" 
}

check_interval() {
    TARGET_FILE_SIZE_B=$1
    FILE_NAME=$2
    
    while [ $CHECK_ONGOING -eq 1 ]
    do
        sleep 5
        echo "[5s timeout - still processing...]"
        file_processed $FILE_NAME && log_progress $TARGET_FILE_SIZE_B $FILE_NAME
        file_processed $FILE_NAME && check_current_file_status $READ_BYTES $TARGET_FILE_SIZE_B
    done
}

reindex_and_measure() {
    curl -XPOST "localhost:9200/plwiki-20200301/_freeze"

    echo "Refreshing index..."
    curl -XPOST "localhost:9200/plwiki-20200301/_refresh"
    sleep 3

    echo "Limiting segments amount to 1..."
    curl -XPOST "localhost:9200/plwiki-20200301/_forcemerge?max_num_segments=1"
    sleep 3

    echo "Fetching statistics after merge of $1 MB data..."
    curl -XGET "localhost:9200/plwiki-20200301/_stats" > "${STATS_DIR}/$1M.json"

    curl -XPOST "localhost:9200/plwiki-20200301/_unfreeze"
}

change_conf_source_file() {
    sed -i "s@${1}@${2}@g" ./xml-plwiki.conf
}

iterate_files() {
    for FILE in ${plwikifiles[@]}
    do
        CHECK_ONGOING=1
        FILE_PATH="${ABS_DATA_DIR}/${FILE}"
        change_conf_source_file $EXCH_STRING $FILE_PATH

        FILE_SIZE_M=$(ls -l --b=M ${FILE_PATH}| cut -d " " -f5 | cut -d "M" -f 1)
        FILE_SIZE_B=$(ls -l ${FILE_PATH}| cut -d " " -f5)
        
        echo "FILE_SIZE_B ${FILE_SIZE_B}"
        check_interval $FILE_SIZE_B $FILE

        SIZE_ACC=$[SIZE_ACC+FILE_SIZE_M]
        reindex_and_measure $SIZE_ACC
        change_conf_source_file $FILE_PATH $EXCH_STRING
    done
}

cd ../data 
ABS_DATA_DIR=$(pwd)
cd -

SIZE_ACC=0

FILE_PATH="${ABS_DATA_DIR}/plwiki-20200301-articles-1.xml"
change_conf_source_file $EXCH_STRING $FILE_PATH

/usr/share/logstash/bin/logstash -f ./xml-plwiki.conf --config.reload.automatic & iterate_files

