library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
#print(getwd())


myArgs <- commandArgs(trailingOnly = TRUE)

# get study name
study_name<- myArgs[1]
# get input json
input <- myArgs[2]

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

source(paste0(strsplit(this_file,'/')[[1]][1],'/calculation_scripts/utils.R'))


calculate_number<- function(dataset,input){
  # get relevant function
  # filter dataset
  dataset <- eval(as.symbol(study_name))
  dataset <- filter_data(dataset,input)

  return(dim(dataset)[1])
}

out = calculate_number(dataset,input)
print(out)
