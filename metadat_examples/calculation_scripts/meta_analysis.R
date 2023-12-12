library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
source('utils.R')


# dat.anand1999
f.anand1999<- function(dataset){
  res <- rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dataset,digits=2)
  return(res)
}

# dat.lehmann2018
f.lehmann2018 <- function(dataset){
  res <- rma(yi, vi, data=dataset, test="knha")
  return(res)
}