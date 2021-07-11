import mygene
import os
import pandas as pd
import logging

logging.basicConfig(format='%(asctime)s: %(message)s', level=logging.INFO)
mg = mygene.MyGeneInfo()
DATA_FOLDER = os.path.join(os.path.dirname(__file__), 'data')


def get_positions():
    logging.info("Reading ENSP of interest")
    input = pd.read_csv(os.path.join(DATA_FOLDER, 'ensp.csv'))
    logging.info("Querying")
    res = mg.querymany(input['protein_external_id'], scopes='ensembl.protein', fields='genomic_pos')
    # df = pd.DataFrame([{'query': i['query'], **i['genomic_pos']} for i in res])

    logging.info(f"Total {len(res)} results")

    # delete all notfounds
    resm = [i for i in res if ('notfound' not in i.keys())]
    logging.info(f"Total {len(resm)} non-empty results")

    # if there are multiple hits, res[i]['genomic'] is a list of dictionaries
    # if there is a single hit, it is a dictionary
    # make a single-hit dictionary a single-element list
    resm = [{'query': i['query'], 'data': i['genomic_pos'] if type(i['genomic_pos']) == list else [i['genomic_pos']]} for i in resm]
    # now it is ready to turn into a dataframe
    df = pd.DataFrame(resm)
    df = df.explode('data').reset_index(drop=True)
    df = df[['query']].join(pd.json_normalize(df['data']))
    logging.info(f"Exploded multiple hits. Total {len(df)} rows")

    # remove non-standard chromosomes
    df = df[df['chr'].isin([str(i) for i in range(1, 23)] + ['X', 'Y'])]
    logging.info(f"Removed non-standard chromosomes. Total {len(df)} rows")

    # remove non-unique queries
    df = df.drop_duplicates(subset=['query'], keep=False)
    logging.info(f"Removed non-unique queries. Total {len(df)} rows")

    df.to_csv(os.path.join(DATA_FOLDER, 'protein_gene_coordinates.csv'), index=False)


if __name__ == '__main__':
    get_positions()
