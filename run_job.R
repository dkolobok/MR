library(glue)
library(ggplot2)
library(logger)

# args = commandArgs()

args <- c('/home/dkolobok/cache/MR/Data/for_jobs/prot-a-1154.csv',
          '/home/dkolobok/cache/MR/Data/selected_outcomes.csv',
          '/home/dkolobok/code/MR',
          '/home/dkolobok/cache/MR/Results'
          )

exp_data = read.csv(args[1])
out_data = read.csv(args[2])
code_dir = args[3]
results_dir = args[4]

setwd(code_dir)
source('bulk_mr.R')

res <- bulk_mr(exp_df=exp_data, out_ids=out_data$id)

if (length(res) > 0) {
  pairs <- res$res %>% dplyr::select(id.exposure, id.outcome) %>% distinct()
  for (df_name in names(res[names(res) != 'p'])) {
    log_info(glue("Saving {df_name}..."))
    dir_name <- glue("{results_dir}/{df_name}")
    if (!dir.exists(dir_name)) dir.create(dir_name)
    write.csv(res[[df_name]], glue("{dir_name}/{exp_data[1, 'id.exposure']}.csv"))
  }
  log_info("Saving individual plots...")
  dir_name <- glue("{results_dir}/plots")
  if (!dir.exists(dir_name)) dir.create(dir_name)
  for (i in 1:nrow(pairs)) {
    plot_name <- glue("{pairs[i, 'id.exposure']}.{pairs[i, 'id.outcome']}")
    ggsave(glue("{dir_name}/{plot_name}.jpg"),
           res$p[[plot_name]])
  }
  log_info("Done!")
}

browser()
