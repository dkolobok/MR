library(logger)
library(dplyr)

data_folder <- '/home/dkolobok/code/MR/data'

# read available outcomes table from cache or from the web
ao_fn <- paste(data_folder, 'mr_available_outcomes.csv', sep='/')
if (file.exists(ao_fn)) ao <- read.csv(ao_fn) else {
  library(TwoSampleMR)
  log_info('Caching available outcomes...')
  ao <- available_outcomes()
  write.csv(ao, ao_fn, row.names = FALSE)
}
  
outcome_df <- ao %>% 
  dplyr::filter(
    stringr::str_detect(trait, 'pneumon|covid|septicemia|sepsis|respiratory infection')
  )

# write to file
outcome_df %>% dplyr::select(id) %>% 
  write.csv(paste(data_folder, 'selected_outcomes.csv', sep='/'), 
            row.names = FALSE)
