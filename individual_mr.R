library(TwoSampleMR)
library(MRInstruments)
library(dplyr)


# args = c("ieu-a-2", "ieu-a-7")
args = commandArgs(trailingOnly=TRUE)

cat("Exposure:", args[1], "\n")
cat("Outcome:", args[2], "\n")

exposure_dat <- extract_instruments(outcomes=args[1])
exposure_dat <- clump_data(exposure_dat)
nrow(exposure_dat)

outcome_dat <- extract_outcome_data(snps=exposure_dat$SNP, outcomes=args[2], 
                                    proxies = 1, rsq = 0.8, align_alleles = 1, 
                                    palindromes = 1, maf_threshold = 0.3)
dat <- harmonise_data(exposure_dat, outcome_dat, action = 2)
res <- mr(dat)
write.csv(res, paste('/net/mraid08/export/genie/Microbiome/Analyses/dkolobok/MR/Results/', args[1], '_vs_', args[2], '.csv', sep=''), row.names = FALSE)

