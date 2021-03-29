library(MRInstruments)
library(dplyr)
library(tidyverse)
data(gwas_catalog)

exposure_df <- gwas_catalog %>% filter(stringr::str_detect(Phenotype_simple, 'immun') | 
                                       stringr::str_detect(Phenotype, 'immun') |
                                       stringr::str_detect(Phenotype_info, 'immun'))

