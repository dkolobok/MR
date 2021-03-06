library(TwoSampleMR)
library(MRInstruments)
# library(dplyr)
library(tidyverse)
# data(gwas_catalog)

# exposure_df <- gwas_catalog %>% filter(stringr::str_detect(Phenotype_simple, 'immun') | 
#                                        stringr::str_detect(Phenotype, 'immun') |
#                                        stringr::str_detect(Phenotype_info, 'immun'))
ao <- available_outcomes()
write.csv(ao, file='c:/users/dkolobok/cache/mr_available_outcomes.csv')
outcome_df <- head(ao %>% filter(stringr::str_detect(trait, 'pneumon|covid|septicemia|sepsis')), 1)

# exposure_df <- head(ao %>% filter(stringr::str_detect(trait, 'immun')))
exposure_df <- head(ao, 1)

system.time({
  exposure_dat <- extract_instruments(outcomes=exposure_df$id)
  exposure_dat <- clump_data(exposure_dat)
  exposure_dat %>% select(id.exposure) %>% distinct() %>% dim()
  
  outcome_dat <- extract_outcome_data(snps=exposure_dat$SNP, outcomes=outcome_df$id, 
                                      proxies = 1, rsq = 0.8, align_alleles = 1, 
                                      palindromes = 1, maf_threshold = 0.3)
  dat <- harmonise_data(exposure_dat, outcome_dat, action = 2)
  res <- mr(dat)
  # het<-mr_heterogeneity(dat)
  # plt<-mr_pleiotropy_test(dat)
  # sin<-mr_singlesnp(dat)
  # all_res<-combine_all_mrresults(res,het,plt,sin,ao_slc=T,Exp=T,split.exposure=F,split.outcome=T)
  
})

res %>% filter(nsnp >= 3 & pval < 0.05)

invisible()

# for (exposure_id in exposure_df$id) 
#   for (outcome_id in outcome_df$id) {
#     exposure_dat <- extract_instruments(outcomes=exposure_id)
#     outcome_dat <- extract_outcome_data(snps=exposure_dat$SNP, outcomes=outcome_id)
#     dat <- harmonise_data(exposure_dat, outcome_dat)
#     res <- mr(dat)
#     TRUE
#   }

# # Get effects of instruments on outcome
# outcome_dat <- extract_outcome_data(snps=exposure_df$SNP, outcomes=outcome_ids)
# 
# # Harmonise the exposure and outcome data
# dat <- harmonise_data(exposure_df, outcome_dat)
# 
# # Perform MR
# res <- mr(dat)