import os

root_dir = '/home/dkolobok/cache/MR'
# root_dir = '/net/mraid08/export/genie/Microbiome/Analyses/dkolobok/MR'

data_dir = os.path.join(root_dir, 'Data')
results_dir = os.path.join(root_dir, 'Results')
qp_running_dir = os.path.join(root_dir, 'Logs')

# rscript_bin = "/net/mraid08/export/jafar/Microbiome/Analyses/dkolobok/opt/miniconda3/envs/r/bin/Rscript"
rscript_bin = "/usr/bin/Rscript"
