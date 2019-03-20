import json
import logging
import argparse
from gams import *
import pdb


def getSymbols(db):
    symbols = []
    for i in db:
        symbols.append(i.name)
    return symbols


def getSymbolTypes(db):
    types = {}
    for i in getSymbols(db):
        t = str(type(db[i])).split("'")[1].split('.')
        types[i] = t[len(t)-1]
    return types


def gdx2json(filename):

    ws = GamsWorkspace(working_directory = "./")
    db = ws.add_database_from_gdx(filename)

    symbolTypes = getSymbolTypes(db)

    d = {}
    for i in symbolTypes.keys():
        d[i] = {}
        if symbolTypes[i] == 'GamsSet':
            if db[i].dimension == 1:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text
                d[i]['elements'] = [rec.keys[0] for rec in db[i]]

                logging.debug('GamsSet %s, entry = %s', i, d[i])
            else:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text
                d[i]['elements'] = [tuple(rec.keys) for rec in db[i]]

                logging.debug('GamsSet %s, entry = %s', i, d[i])

        elif symbolTypes[i] == 'GamsParameter':
            if db[i].dimension == 0:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text
                d[i]['values'] = db[i].first_record().value

                logging.debug('GamsParameter %s, entry = %s', i, d[i])

            elif db[i].dimension == 1:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text

                d[i]['values'] = {}
                d[i]['values']['domain'] =  [rec.keys[0] for rec in db[i]]
                d[i]['values']['data'] = [rec.value for rec in db[i]]

                logging.debug('GamsParameter %s, entry = %s', i, d[i])

            else:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text

                d[i]['values'] = {}
                d[i]['values']['domain'] =  [tuple(rec.keys) for rec in db[i]]
                d[i]['values']['data'] = [rec.value for rec in db[i]]

                logging.debug('GamsParameter %s, entry = %s', i, d[i])

        elif symbolTypes[i] == 'GamsVariable':
            if db[i].dimension == 0:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text
                d[i]['vartype'] = db[i].vartype

                d[i]['values'] = {}
                d[i]['values']['domain'] =  []
                d[i]['values']['lower'] = db[i].first_record().lower
                d[i]['values']['level'] = db[i].first_record().level
                d[i]['values']['upper'] = db[i].first_record().upper
                d[i]['values']['scale'] = db[i].first_record().scale
                d[i]['values']['marginal'] = db[i].first_record().marginal

                logging.debug('GamsVariable %s, entry = %s', i, d[i])

            elif db[i].dimension == 1:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text
                d[i]['vartype'] = db[i].vartype

                d[i]['values'] = {}
                d[i]['values']['domain'] =  [rec.keys[0] for rec in db[i]]
                d[i]['values']['lower'] = [rec.lower for rec in db[i]]
                d[i]['values']['level'] = [rec.level for rec in db[i]]
                d[i]['values']['upper'] = [rec.upper for rec in db[i]]
                d[i]['values']['scale'] = [rec.scale for rec in db[i]]
                d[i]['values']['marginal'] = [rec.marginal for rec in db[i]]

                logging.debug('GamsVariable %s, entry = %s', i, d[i])

            else:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text
                d[i]['vartype'] = db[i].vartype

                d[i]['values'] = {}
                d[i]['values']['domain'] =  [tuple(rec.keys) for rec in db[i]]
                d[i]['values']['lower'] = [rec.lower for rec in db[i]]
                d[i]['values']['level'] = [rec.level for rec in db[i]]
                d[i]['values']['upper'] = [rec.upper for rec in db[i]]
                d[i]['values']['scale'] = [rec.scale for rec in db[i]]
                d[i]['values']['marginal'] = [rec.marginal for rec in db[i]]

                logging.debug('GamsVariable %s, entry = %s', i, d[i])


        elif symbolTypes[i] == 'GamsEquation':
            if db[i].dimension == 0:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text

                d[i]['values'] = {}
                d[i]['values']['domain'] =  []
                d[i]['values']['lower'] = db[i].first_record().lower
                d[i]['values']['level'] = db[i].first_record().level
                d[i]['values']['upper'] = db[i].first_record().upper
                d[i]['values']['scale'] = db[i].first_record().scale
                d[i]['values']['marginal'] = db[i].first_record().marginal

                logging.debug('GamsEquation %s, entry = %s', i, d[i])


            elif db[i].dimension == 1:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text

                d[i]['values'] = {}
                d[i]['values']['domain'] =  [rec.keys[0] for rec in db[i]]
                d[i]['values']['lower'] = [rec.lower for rec in db[i]]
                d[i]['values']['level'] = [rec.level for rec in db[i]]
                d[i]['values']['upper'] = [rec.upper for rec in db[i]]
                d[i]['values']['scale'] = [rec.scale for rec in db[i]]
                d[i]['values']['marginal'] = [rec.marginal for rec in db[i]]

                logging.debug('GamsEquation %s, entry = %s', i, d[i])

            else:
                d[i]['type'] = symbolTypes[i]
                d[i]['dimension'] = db[i].dimension
                d[i]['domain'] = db[i].domains_as_strings
                d[i]['number_records'] = db[i].number_records
                d[i]['text'] = db[i].text

                d[i]['values'] = {}
                d[i]['values']['domain'] =  [tuple(rec.keys) for rec in db[i]]
                d[i]['values']['lower'] = [rec.lower for rec in db[i]]
                d[i]['values']['level'] = [rec.level for rec in db[i]]
                d[i]['values']['upper'] = [rec.upper for rec in db[i]]
                d[i]['values']['scale'] = [rec.scale for rec in db[i]]
                d[i]['values']['marginal'] = [rec.marginal for rec in db[i]]

                logging.debug('GamsEquation %s, entry = %s', i, d[i])
    return d


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--in', action="store", dest='inFilename', default='out.gdx', type=str)
    args = parser.parse_args()


    filename = args.inFilename

    logging.basicConfig(filename=filename.split('.')[0]+'.log', filemode='w', level=logging.DEBUG)

    a = gdx2json(filename)


    with open(filename.split('.')[0]+'.json', 'w') as outfile:
        json.dump(a, outfile, indent=4)



