library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
#print(getwd())


myArgs <- commandArgs(trailingOnly = TRUE)

# get study name
study_name<- myArgs[1]
filename <- myArgs[2]


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
input <- fromJSON(paste0(strsplit(this_file,'/')[[1]][1],'/custom_filters/',filename))


calculate_number<- function(study_name,input){
  # get relevant function
  # filter dataset
  dataset <- eval(as.symbol(study_name))
  dataset <- filter_data(dataset,input)

  return(dim(dataset)[1])
}

out = calculate_number(study_name,input)
print(out)
