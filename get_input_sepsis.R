# ao <- available_outcomes()
# write.csv(ao, file='/home/dkolobok/code/MR/data/mr_available_outcomes.csv')
data_folder <- '/home/dkolobok/code/MR/data'

ao <- read.csv(paste(data_folder, 'mr_available_outcomes.csv', sep='/'))
outcome_df <- ao %>% dplyr::filter(stringr::str_detect(trait, 'pneumon|covid|septicemia|sepsis'))

# the original string database table can be processed by 
# sed 's/;.*//; s/9606.//' 9606.protein.info.v11.0.txt > stringdb.txt
# (delete everything after ; and delete '9606.' prefix)
string_db <- read.csv(paste(data_folder, 'stringdb.txt', sep='/'), sep='\t')
string_db <- string_db %>% dplyr::rename(protein_name = annotation)

exposure_df <- ao %>% dplyr::filter(stringr::str_detect(id, 'prot-')) %>% 
  dplyr::rename(protein_name = trait)

# finds 3032 out of 4489 proteins
exposure_df <- exposure_df %>% inner_join(string_db, by='protein_name')

exposure_df %>% dplyr::select(protein_external_id) %>% distinct() %>% 
  write.csv(paste(data_folder, 'ensp.csv', sep='/'), row.names = FALSE)

# run mygene_coordinates.py
protein_gene_coordinates <- read.csv(paste(data_folder, 'protein_gene_coordinates.csv', sep='/')) %>% 
  dplyr::rename(protein_external_id = query)

exposure_df <- exposure_df %>% inner_join(protein_gene_coordinates, by='protein_external_id') %>% 
  dplyr::select(id, preferred_name, chr, start, end)


# 25: 161
indf <- exposure_df %>% mutate(id.outcome = 'ieu-b-69') %>% 
  dplyr::rename(id.exposure = id)

