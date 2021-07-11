library(purrrlyr)

# drops suffix from all columns names
drop_suffix <- function(df, suffix='.exposure') {
  browser()
  return(df %>% rename_at(.vars = vars(ends_with(suffix)),
                   .funs = funs(sub(glue("{suffix}$"), "", .))) %>% 
           subset(select=which(!duplicated(names(.)))) 
         )
}

bulk_mr <- function(indf, pval=1e-5, delta=100000) {
  exp_df <- indf %>% 
    dplyr::select(id.exposure, chr, start, end) %>% 
    distinct() #%>% head(2)
  log_info(glue("Getting variants for {nrow(exp_df)} exposures"))
  exp_dat_mr <- exp_df %>% by_row(function(x) ind_mr(x, delta=delta, pval_threshold=pval), .collate='rows', .labels = FALSE)
  exp_dat_mr <- exp_dat_mr %>% mutate(mr_keep = TRUE) %>% 
    dplyr::rename(SNP = rsid, id.exposure = id, 
           exposure = trait, beta.exposure = beta, 
           se.exposure = se, 
           effect_allele.exposure = ea, 
           other_allele.exposure = nea,
           eaf.exposure = eaf)
  
  out_ids <- unique(indf$id.outcome)
  out_dat <-
    extract_outcome_data(snps = exp_dat_mr$SNP, outcomes = out_ids)
  dat <- harmonise_data(exp_dat_mr, out_dat)

  # # leave only pairs present in indf
  # dat <- dat %>% inner_join(indf,
  #                           by = c('id.exposure', 'id.outcome'))
  # 
  # dat <- dat %>% mutate(label = paste(chr, pos, sep = ":"))
  # 
  # # cis-MR: leave only SNPs with gene boundaries +- delta
  # dat <- dat %>% filter((chr == Chromosome) & (Gene.start..bp. - delta <= pos) & (Gene.end..bp. + delta >= pos))

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
