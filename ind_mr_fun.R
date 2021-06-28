library(TwoSampleMR)
library(dplyr)

perform_mr <- function(indf, pval=5e-7, delta=100000) {
  exp_ids <- unique(indf$id.exposure)
  out_ids <- unique(indf$id.outcome)
  
  vars <- ieugwasr::variants_gene(gene, radius = 0)
  
  
  system.time(
  exp_dat <- extract_instruments(outcomes = exp_ids, 
                                 p1=pval, p2=pval,
                                 force_server=TRUE)
  )
  out_dat <-
    extract_outcome_data(snps = exp_dat$SNP, outcomes = out_ids)
  dat <- harmonise_data(exp_dat, out_dat)
  
  # leave only pairs present in indf
  dat <- dat %>% inner_join(indf,
                            by = c('id.exposure', 'id.outcome'))
  
  dat <- dat %>% mutate(label = paste(chr, pos, sep = ":"))
  
  # cis-MR: leave only SNPs with gene boundaries +- delta
  dat <- dat %>% filter((chr == Chromosome) & (Gene.start..bp. - delta <= pos) & (Gene.end..bp. + delta >= pos))
  
  res <- mr(dat)
  het <- mr_heterogeneity(dat)
  plt <- mr_pleiotropy_test(dat)
  sin <- mr_singlesnp(dat)
  p <- plot_scatter(res, dat)
  
  #  p2 <- p$`prot-b-11.ukb-a-577` +
  #    geom_label(dat, mapping = aes(x = beta.exposure,
  #                                  y = beta.outcome,
  #                                  label = label))
  
  invisible()
  return(list(
    dat = dat,
    res = res,
    het = het,
    plt = plt,
    sin = sin,
    p = p
  ))
}
