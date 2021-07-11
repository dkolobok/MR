library(tidyr)
library(glue)

data_folder <- '/home/dkolobok/code/MR/data'

indf <- read.csv(glue('{data_folder}/prot_vs_prolapse_filtered.csv'), na.strings = c('.')) %>% dplyr::select(one_of(c(
  'id.exposure',
  'id.outcome',
  'Gene',
  'Chromosome',
  'Gene.start..bp.',
  'Gene.end..bp.',
  "Strand",
  "Band",
  "Function"
))) %>% dplyr::distinct() %>% drop_na('Gene.start..bp.')

# top exposures
top_exp <- c("prot-a-2908", "prot-a-607",  "prot-a-1445", "prot-a-545",
             "prot-a-1154", "prot-a-1305", "prot-a-96", "prot-a-2397",
             "prot-a-1369", "prot-a-2243")
indf <- indf %>% dplyr::filter(id.exposure %in% top_exp)
