

library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
myArgs <- commandArgs(trailingOnly = TRUE)

setwd('/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/metadat_examples')

# load dataset
dataset <- eval(as.symbol(myArgs[1]))
# get input json
input <- myArgs[2]

calculate_meta <- function(dataset,input){
  # remove [] at beginning and end
  input <- substring(input,2,nchar(input)-1)
  # split into parts
  inputs <- strsplit(input, '},')[[1]]
  #input1 <- fromJSON(gsub("'","\"", paste0(inputs[4],'}')))
  
  for (i in (1:length(inputs))){
    # format correctly
    if (i < length(inputs)){
      input <- fromJSON(gsub("'","\"", paste0(inputs[i],'}')))
    } else { input <- fromJSON(gsub("'","\"",inputs[i])) }
    
    # filter data
    id <- input$id
    values <- input$values
    dataset <- dataset %>% subset(eval(as.symbol(id)) %in% values)
  }
  
  # run analysis 
  res <- rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dataset,digits=2)
  out <- create_return(dataset,res)
  return(out)
}

calculate_meta(dataset,input)

