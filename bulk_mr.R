library(dplyr)
library(purrrlyr)
library(logger)
library(glue)
library(ggplot2)
source('ind_mr.R')
source('plot_scatter.R')

# drops suffix from all columns names
drop_suffix <- function(df, suffix='.exposure') {
  browser()
  return(df %>% rename_at(.vars = vars(ends_with(suffix)),
                   .funs = funs(sub(glue("{suffix}$"), "", .))) %>% 
           subset(select=which(!duplicated(names(.)))) 
         )
}

# performs bulk cis-MR for every exposure from exp_df against every outcome in out_ids
bulk_mr <- function(exp_df, out_ids, pval=1e-5, delta=100000) {
  log_info(glue("Getting variants for {nrow(exp_df)} exposures"))
  exp_dat_mr <- exp_df %>% by_row(function(x) get_instruments_ind(x, delta=delta, pval_threshold=pval), .collate='rows', .labels = FALSE)
  
  if (nrow(exp_dat_mr) == 0) {
    log_info("No variants for this exposure, exiting...")
    return(list())
  }
  
  exp_dat_mr <- exp_dat_mr %>% mutate(mr_keep = TRUE) %>% 
    dplyr::rename(SNP = rsid, id.exposure = id, 
           exposure = trait, beta.exposure = beta, 
           se.exposure = se, 
           effect_allele.exposure = ea, 
           other_allele.exposure = nea,
           eaf.exposure = eaf)
  
  out_dat <-
    extract_outcome_data(snps = exp_dat_mr$SNP, outcomes = out_ids)
  dat <- harmonise_data(exp_dat_mr, out_dat)

  res <- mr(dat)
  het <- mr_heterogeneity(dat)
  plt <- mr_pleiotropy_test(dat)
  sin <- mr_singlesnp(dat)
  p <- plot_scatter(res, dat)
  return(list(
    dat = dat,
    res = res,
    het = het,
    plt = plt,
    sin = sin,
    p = p
  ))
}
