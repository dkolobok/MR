library(dplyr)

res <- read.csv('c:/users/dkolobok/Downloads/prot_vs_prolapse.csv')
res <- res %>% filter(nsnp > 1) %>% arrange(id.exposure, id.outcome)
