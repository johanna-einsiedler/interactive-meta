
library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
source('utils.R')


check_filtering <- function(dataset,input){
  # filter dataset
  init_dim <- dim(dataset)
  dataset <- try(filter_data(dataset,input))
  if (inherits(dataset,'try-error')){
    return('failed')
  } else{
  final_dim <- dim(dataset)
  same_dim <- try(init_dim[1]!=final_dim[1])
  if (inherits(same_dim, "try-error")) {
    return('failed')}
  else {
  if (same_dim){
    return('failed')
  } else{return('success')}
  }
  }
}


# get list of studies
file_list <- list.files(path = '/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/filter_descriptions', recursive = TRUE)
file_list <- gsub('.txt','',file_list)

results <- c()
for (study_name in file_list){
  # load dataset
  dataset <- eval(as.symbol(study_name))
  # get input json
  input <- fromJSON(paste0('/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/filter_descriptions/',study_name,'.txt'))
  input <- toJSON(input)
  
  out <- check_filtering(dataset,input)
  results <- rbind(results,c(study_name,out))
}

# print which ones failed
results[results[,2]=='failed',1]
