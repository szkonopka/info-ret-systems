#!/bin/bash

declare -a plwikifiles=(
    "plwiki-20200301-pages-articles-multistream1.xml-p1p169750.bz2"
    "plwiki-20200301-pages-articles-multistream2.xml-p169751p510662.bz2"
    "plwiki-20200301-pages-articles-multistream3.xml-p510663p1056310.bz2"
    "plwiki-20200301-pages-articles-multistream4.xml-p1056311p1831508.bz2"
    "plwiki-20200301-pages-articles-multistream5.xml-p1831509p3070393.bz2"
    "plwiki-20200301-pages-articles-multistream6.xml-p3070394p4570393.bz2"
    "plwiki-20200301-pages-articles-multistream6.xml-p4570394p4727706.bz2"
)

for index in ${!plwikifiles[@]}
do
    fileid=$[index+1]
    echo "Downloading plwikifiles - ${fileid}. ${plwikifiles[$index]}"
    wget "https://dumps.wikimedia.org/plwiki/20200301/${plwikifiles[$index]}" -O plwiki-20200301-articles-${fileid}.xml.bz2
    bzip2 -d plwiki-20200301-articles-${fileid}.xml.bz2
done