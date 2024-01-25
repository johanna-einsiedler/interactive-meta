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

source(paste0(strsplit(this_file,'/')[[1]][1],'/api_calculation/utils.R'))
source(paste0(strsplit(this_file,'/')[[1]][1],'/api_calculation/meta_analysis.R'))

#source('utils.R')
#source('meta_analysis.R')

myArgs <- commandArgs(trailingOnly = TRUE)

# get study name
study_name<- myArgs[1]
# get input json
filename <- myArgs[2]
#print(input)
# test
#study_name <- 'dat.aloe2013'
#dataset <- eval(as.symbol(study_name))
#inputs <- fromJSON(paste0('/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/filter_descriptions/',study_name,'.txt'))
#input <- toJSON(input)

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
#input <- fromJSON(paste0(strsplit(this_file,'/')[[1]][1],'/filter_descriptopns/',study_name,'.txt'))
#print(paste0(strsplit(this_file,'/')[[1]][1],'/custom_filters/',filename))
input <- fromJSON(paste0(strsplit(this_file,'/')[[1]][1],'/custom_filters/',filename))
# <- fromJSON('/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/api_calculation/custom_filters/faaae074-5f6a-4966-ba68-d12db18b96a8.json')
#input <- fromJSON('/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples/api_calculation/custom_filters/bangertowns_test.json')

calculate_meta <- function(study_name,input){
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


