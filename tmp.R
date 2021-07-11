library(glue)
library(tidyverse)
library(purrrlyr)
library(mygene)
library(purrr)

source('ind_mr.R')
source('plot_scatter.R')
# source('get_input.R')
source('get_input_sepsis.R')
source('ind_mr.R')
source('bulk_mr.R')
ieugwasr::get_access_token()

system.time({
  res <- bulk_mr(indf)
})

browser()
