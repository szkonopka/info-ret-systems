#!/bin/bash


get_zamach_stanu() {
    curl -X GET "localhost:9200/plwiki-20200301/_search?pretty" -H 'Content-Type: application/json' -d'
    {
        "from": 0, "size": 4000,
        "query": {
            "query_string" : {
                "query": "Zamach stanu"
            }
        }
    }
    '
}

get_trump() {
    curl -X GET "localhost:9200/plwiki-20200301/_search?pretty" -H 'Content-Type: application/json' -d'
    {
        "from": 0, "size": 4000,
        "query": {
            "query_string" : {
                "query": "Donald trump"
            }
        }
    }
    '
}

get_wisla_krakow() {
    curl -X GET "localhost:9200/plwiki-20200301/_search?pretty" -H 'Content-Type: application/json' -d'
    {
        "from": 0, "size": 4000,
        "query": {
            "query_string" : {
                "query": "Wisła Kraków piłka nożna"
            }
        }
    }
    '
}

get_zamach_stanu > ./query-results/zamach_stanu-results.json
get_wisla_krakow > ./query-results/wisla_krakow_pilka_nozna-results.json
get_trump > ./query-results/donald_trump-results.json