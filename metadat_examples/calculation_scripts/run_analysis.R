library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
#print(getwd())

get_this_file <- function() {
  commandArgs() %>%
    tibble::enframe(name = NULL) %>%
    tidyr::separate(
      col = value, into = c("key", "value"), sep = "=", fill = "right"
    ) %>%
    dplyr::filter(key == "--file") %>%
    dplyr::pull(value)
}
this_file <- get_this_file()
#source('utils.R')
source(paste0(strsplit(this_file,'/')[[1]][1],'/calculation_scripts/utils.R'))

source('meta_analysis.R')

myArgs <- commandArgs(trailingOnly = TRUE)

# get study name
study_name<- myArgs[1]
# get input json
input <- myArgs[2]
#print(input)
# test
#study_name <- 'dat.aloe2013'
#dataset <- eval(as.symbol(study_name))
#input <- fromJSON(paste0('/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/filter_descriptions/',study_name,'.txt'))
#input <- toJSON(input)


calculate_meta <- function(dataset,input){
  # get relevant function
  function_name <- paste0('f.',str_split(study_name,'\\.')[[1]][2])
  # filter dataset
  dataset <- eval(as.symbol(study_name))
  dataset <- filter_data(dataset,input)
  #print(dataset)
  # run analysis 

  res <- eval(as.symbol(function_name))(dataset)
  # format return table
  out <- create_return(dataset,res)
  return(out)
}

 out = calculate_meta(dataset,input)
print(out)

