library(TwoSampleMR)
library(dplyr)
library(tidyverse)
ao <- available_outcomes()

exposure_ids <- ao %>% filter(stringr::str_detect(id, 'prot-')) %>% select(id)
exposure_df <- extract_instruments(outcomes=exposure_ids$id)

outcome_ids <- ao %>% filter(stringr::str_detect(trait, 'prolap')) %>% select(id)
outcome_df <- extract_outcome_data(
  snps = exposure_df$SNP,
  outcomes = outcome_ids$id
)

dat <- harmonise_data(
  exposure_dat = exposure_df, 
  outcome_dat = outcome_df
)

system.time({
  res <- mr(dat)
})

