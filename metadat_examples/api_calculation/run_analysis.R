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

myArgs <- commandArgs(trailingOnly = TRUE)

# get study name
study_name<- myArgs[1]
# get input json
filename <- myArgs[2]
input <- fromJSON(gsub("api_calculation/", "", paste0(strsplit(this_file,'/')[[1]][1],'/',strsplit(this_file,'/')[[1]][2],'/custom_filters/',filename)))

# calculate_meta <- function(study_name,input){
# get_this_file <- function() {
#   commandArgs() %>%
#     tibble::enframe(name = NULL) %>%
#     tidyr::separate(
#       col = value, into = c("key", "value"), sep = "=", fill = "right"
#     ) %>%
#     dplyr::filter(key == "--file") %>%
#     dplyr::pull(value)
# }
# this_file <- get_this_file()
# input <- fromJSON(paste0(strsplit(this_file,'/')[[1]][1],'/custom_filters/',filename))
# }

# out = calculate_meta(study_name,input)
# print(out)

calculate_meta <- function(dataset,input){
  # get relevant function
  function_name <- paste0('f.',str_split(study_name,'\\.')[[1]][2])
  # filter dataset
  dataset <- eval(as.symbol(study_name))
  dataset <- filter_data(dataset,input)

  print(dataset)
  # run analysis 

  res <- eval(as.symbol(function_name))(dataset)
  # format return table
  out <- create_return(dataset,res)
  return(out)
}

 out = calculate_meta(dataset,input)
print(out)