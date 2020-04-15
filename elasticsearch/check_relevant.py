import json

JSON_DIR='./query-results/'

FILES = {
    'donald trump': 'donald_trump-results.json',
    'wisła kraków piłka nożna': 'wisla_krakow_pilka_nozna-results.json',
    'zamach stanu': 'zamach_stanu-results.json'
}

DOC_ID_FILES = {
    'donald trump': 'donald_trump_doc_ids_elastic.txt',
    'wisła kraków piłka nożna': 'wisla_krakow_pilka_nozna_doc_ids_elastic.txt',
    'zamach stanu': 'zamach_stanu_doc_ids_elastic.txt'
}

def count_relevant_queries(query, file_name):
    count = 0

    with open(JSON_DIR + file_name) as json_file:
        data = json.load(json_file)

    for hit in data['hits']['hits']:
        with open('../' + DOC_ID_FILES[query], 'a') as doc_id_file:
            doc_id_file.write(hit['_id'] + '\n')

        if query in hit['_source']['title'].lower() or query in hit['_source']['text'][0].lower():
            count = count + 1

    return count

for query, file_name in FILES.items():
    print("{} - relevant docs: {}".format(query, count_relevant_queries(query, file_name)))