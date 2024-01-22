library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
#print(getwd())

source('utils.R')
source('meta_analysis.R')

myArgs <- commandArgs(trailingOnly = TRUE)

# get study name
study_name<- myArgs[1]
# get input json
input <- myArgs[2]



calculate_number<- function(dataset,input){
  # get relevant function
  # filter dataset
  dataset <- eval(as.symbol(study_name))
  dataset <- filter_data(dataset,input)

  return(dim(dataset)[1])
}



