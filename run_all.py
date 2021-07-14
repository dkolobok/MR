import os
import pandas as pd
import logging

from config import qp_running_dir, rscript_bin, data_dir, results_dir
from LabQueue.qp import qp, fakeqp

logging.basicConfig(format='%(asctime)s: %(message)s', level=logging.INFO)


class RunAll(object):
    def __init__(self):
        self.code_dir = os.path.dirname(__file__)
        self.for_jobs_dir = os.path.join(data_dir, 'for_jobs')
        os.makedirs(self.for_jobs_dir, exist_ok=True)
        os.makedirs(results_dir, exist_ok=True)
        pass

    def run_individual_mr(self, outcome_fn, row):
        exp_fn = os.path.join(self.for_jobs_dir, f"{row['id.exposure']}.csv")
        row.to_frame().T.to_csv(exp_fn, index=False)
        rscript_path = os.path.join(self.code_dir, 'run_job.R')
        os.system(f"{rscript_bin} {rscript_path} {exp_fn} {outcome_fn} {self.code_dir} {results_dir}")

    def run(self):
        outcome_fn = os.path.join(data_dir, 'selected_outcomes.csv')
        exposure_df = pd.read_csv(os.path.join(data_dir, 'selected_exposures.csv'))
        os.chdir(qp_running_dir)
        with fakeqp(jobname='mr', max_r=30, delay_sec=3, _delete_csh_withnoerr=True,
                    _mem_def='3G') as q:
            q.startpermanentrun()
            logging.info(f"Running MR for {len(pd.read_csv(outcome_fn))} outcomes and {len(exposure_df)} exposures...")
            wait_on = {row['id.exposure']: q.method(self.run_individual_mr, args=(outcome_fn, row,)) for i, row in exposure_df[exposure_df['id.exposure'] == 'prot-a-1154'].iterrows()}
            rets = {ido: q.waitforresult(ret) for ido, ret in wait_on.items()}



        pass


if __name__ == '__main__':
    RunAll().run()

