#!/bin/bash

declare -a plwikifiles=(
    "plwiki-20200301-pages-articles-multistream1.xml-p1p169750.bz2"
)

for index in ${!plwikifiles[@]}
do
    fileid=$[index+1]
    echo "Downloading plwikifiles - ${fileid}. ${plwikifiles[$index]}"
    wget "https://dumps.wikimedia.org/plwiki/20200301/${plwikifiles[$index]}" -O plwiki-20200301-articles-${fileid}.xml.bz2
    bzip2 -d plwiki-20200301-articles-${fileid}.xml.bz2
done
