#!/bin/sh

wget "https://dumps.wikimedia.org/plwiki/20200301/plwiki-20200301-pages-articles-multistream.xml.bz2" -O plwiki-20200301-articles.xml.bz2
bzip2 -d plwiki-20200301-articles.xml.bz2