indf <- read.csv('c:/users/dkolobok/Downloads/prot_vs_prolapse_filtered.csv', na.strings = c('.')) %>% select(one_of(c(
  'id.exposure',
  'id.outcome',
  'Gene',
  'Chromosome',
  'Gene.start..bp.',
  'Gene.end..bp.',
  "Strand",
  "Band",
  "Function"
))) %>% distinct() %>% drop_na('Gene.start..bp.')

# select exposures for which 'finn...' outcomes are present
valid_exp <- (indf %>% filter(stringr::str_detect(id.outcome, 'finn')))$id.exposure %>% unique()

indf <- indf %>% filter(id.exposure %in% valid_exp)
