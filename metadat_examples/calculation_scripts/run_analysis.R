library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
source('utils.R')
source('run_analysis.R')


myArgs <- commandArgs(trailingOnly = TRUE)

# load dataset
dataset <- eval(as.symbol(myArgs[1]))
# get input json
input <- myArgs[2]




calculate_meta <- function(dataset,input){
  # filter dataset
  dataset <- filter_data(dataset,input)
  # run analysis 
  # formt return table
  #out <- create_return(dataset,res)
  print(res)
  #return(out)
}

calculate_meta(dataset,input)
