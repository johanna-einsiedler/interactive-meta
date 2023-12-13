library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
source('utils.R')
source('meta_analysis.R')


myArgs <- commandArgs(trailingOnly = TRUE)

# load dataset
dataset <- eval(as.symbol(myArgs[1]))
# get input json
input <- myArgs[2]

# test
study_name <- 'dat.anand1999'
dataset <- eval(as.symbol(study_name))
input <- fromJSON(paste0('/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/filter_descriptions/',study_name,'.txt'))
input <- toJSON(input)


calculate_meta <- function(dataset,input){
  # filter dataset
  dataset <- filter_data(dataset,input)
  # run analysis 
  # get relevant function
  function_name <- paste0('f.',str_split(study_name,'\\.')[[1]][2])
  res <- eval(as.symbol(function_name))(dataset)
  # format return table
  out <- create_return(dataset,res)
}

calculate_meta(dataset,input)
