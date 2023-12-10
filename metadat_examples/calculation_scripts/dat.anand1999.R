


library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
source('calculation_scripts/utils.R')

myArgs <- commandArgs(trailingOnly = TRUE)

# load dataset
dataset <- eval(as.symbol(myArgs[1]))
# get input json
input <- myArgs[2]

calculate_meta <- function(dataset,input){
  # filter dataset
  dataset <- filter_data(dataset,input)
  # run analysis 
  res <- rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dataset,digits=2)
  # formt return tabel
  out <- create_return(dataset,res)
  return(out)
}

calculate_meta(dataset,input)
