

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
  #create dataframe with study data
  study_names <- paste0(dataset$study,', ', dataset$year)[res$not.na.yivi]
  measure <- exp(res$yi)
  participants <- attr(res$yi, 'ni')
  ci_lower <- exp(res$yi -sqrt(res$vi)* qt(0.975, df = participants-1))
  ci_upper <- exp(res$yi +sqrt(res$vi)* qt(0.975, df = participants-1))

  out <- tibble(study_names, measure, participants, ci_lower, ci_upper)
  # add metastudy result
  meta <- data.frame(study_names='Random Effects Model',
                     measure=exp(res$beta)[1], 
                     participants = sum(participants), 
                     ci_lower = exp(res$ci.lb),
                     ci_upper = exp(res$ci.ub))
  # create json to export
  out <- rbind(out,meta)
  out <- out %>% mutate(across(where(is.numeric), \(x) round(x,digits=2)))
  
  out_json <- toJSON(out)
  return(out_json)
}

calculate_meta(dataset,input)
