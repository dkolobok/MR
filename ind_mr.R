library(TwoSampleMR)
library(dplyr)
library(logger)
library(glue)
library(mygene)
library(gwasglue)



# function that takes exposure id and returns 
# a list of urls to download (vcf + tbi)
ieu_urls <- function(exp_id) {
  add_tbi <- function(str) paste(str, '.tbi', sep='')
  vcf_fn <- paste(glue('{exp_id}.vcf.gz'))
  tbi_fn <- add_tbi(vcf_fn)
  vcf_url <- paste(glue('https://gwas.mrcieu.ac.uk/files/{exp_id}/{vcf_fn}'))
  download_list <- list(vcf_url, add_tbi(vcf_url))
  names(download_list) <- list(vcf_fn, tbi_fn)
  return(download_list)
}

# perform MR for a single exposure
get_ind_gwas <- function(exp_id, pval, delta, data_path = 'data/exp_vcf', 
                   url_fun=ieu_urls) {
  download_list <- url_fun(exp_id)
  download_status <- list()
  for (key in names(download_list)) {
    dest <- paste(data_path, key, sep='/')
    if (!file.exists(key)) {
      log_info(glue('Downloading {key}...'))
      download_status[key] <- download.file(url=download_list[[key]], 
                                            destfile=dest)
    }
  }
  log_info('Download completed.')
}

ind_mr <- function(row, pval_threshold, delta) {
  exp_id <- row$id.exposure
  chr <- row$chr
  start <- row$start
  end <- row$end
  log_info(glue("Processing exposure id {exp_id}"))
  counter <- 0
  while (counter < 3) {
    try(vars <- ieugwasr::associations(variants=glue("{chr}:{start-delta}-{end+delta}"),
                                       id=exp_id))
    if (is.data.frame(vars)) break
    counter <- counter + 1
  }
  
  # handle problems
  if (counter == 3) {
    log_info("Three unsuccessful attempts to get data (most likely too many variants to access or connection problems). Ignoring this exposure.")
    return()
  }
  if (nrow(vars) == 0) {
    log_info("No data available. Ignoring this exposure.")
    return()
  }
  
  ntotal_vars <- nrow(vars)
  log_info(glue("{ntotal_vars} variants loaded for {exp_id}"))
  vars <- vars %>% filter(p <= pval_threshold)
  nfiltered_vars <- nrow(vars)
  log_info(glue("{nfiltered_vars} variants passed pvalue threshold {pval_threshold}"))
  vars <- vars %>% dplyr::rename(pval = p)
  vars <- vars %>% mutate(Gene = row$Gene, Strand = row$Strand, Band = row$Band, Function = row$Function,
                          total_snps = ntotal_vars, filtered_snps = nfiltered_vars,
                          label = glue("{chr}:{position}"))
  if (nrow(vars) == 0)
    return(vars %>% dplyr::select(sort(tidyselect::peek_vars())))
  cl_vars <- ld_clump(vars, clump_kb=1000, clump_r2 = 0.01)
  
  
  
  cl_vars <- cl_vars %>% dplyr::select(sort(tidyselect::peek_vars()))
  return(cl_vars)
}