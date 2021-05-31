import itertools
import logging
import os

import pandas as pd
from LabQueue.qp import fakeqp, qp
from LabUtils.addloglevels import sethandlers

from config import available_outcomes_fn, qp_running_dir

_log = logging.getLogger(__name__)


class CheckMultiplePairs(object):
    """ Calculates causal effect for multiple exposure-outcome pairs """
    def __init__(self, debug=False):
        self._queue = fakeqp if debug else qp
        self.available_outcomes = pd.read_csv(available_outcomes_fn).dropna(subset=['trait'])
        self.val_exp_cat = ['Protein', 'Lipid', 'Unknown metabolite',
                            'Amino acid', 'Fatty acid', 'Immune cell subset frequency', 'Haemotological',
                            'Hormone', 'Biomarker', 'Nucleotide', 'Carbohydrate', 'Peptide']
        self.val_out_regex = r"pneumon|covid|septicemia|sepsis"

    def routine(self):
        exposures = self.get_exposures()
        outcomes = self.get_outcomes()
        self.run_mr(exposures=exposures, outcomes=outcomes)

    def run_mr(self, exposures, outcomes):
        os.chdir(qp_running_dir)
        pairs = list(itertools.product(exposures, outcomes))
        with self._queue(jobname='mr', max_r=30, delay_sec=3, _delete_csh_withnoerr=True,
                         _mem_def='3G') as q:
            q.startpermanentrun()
            _log.info(f"Running MR for {len(pairs)} pairs...")
            wait_on = {pair: q.method(self.run_individual_mr, args=(pair,)) for pair in pairs}
            rets = {pair: q.waitforresult(ret) for pair, ret in wait_on.items()}

    def run_individual_mr(self, pair):
        pass

    def get_exposures(self):
        exposures = self.available_outcomes.query('subcategory in @self.val_exp_cat')['id']
        return exposures.tolist()

    def get_outcomes(self):
        outcomes = self.available_outcomes.loc[self.available_outcomes['trait'].str.contains(self.val_out_regex), 'id']
        return outcomes.tolist()


if __name__ == '__main__':
    sethandlers()
    CheckMultiplePairs(debug=True).routine()