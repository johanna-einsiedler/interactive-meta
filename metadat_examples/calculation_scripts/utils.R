library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)



filter_data <- function(dataset, input){

  # remove [] at beginning and end
  input <- substring(input,2,nchar(input)-1)
  # split into parts
  inputs <- strsplit(input, '},')[[1]]

  for (i in (1:length(inputs))){
    # format correctly
  if (i < length(inputs)){
      input <- fromJSON(paste0(inputs[i],'}'))
    } else { input <- fromJSON(paste0(inputs[i])) }
    
    # filter data
    var_id <- input$id
    #print(var_id)
    values <- input$values
    if (typeof(values)=='integer'){
      values <- as.list(values)} else {
    values <- sapply(values, function(x) gsub('\"','', as.list(el(strsplit(values, ',\"')))))
}
    # check if na values are there and replace with true NA

    values[values=='NA']<- NA
    
   # print(values)
    
    dataset <- dataset %>% filter(eval(as.symbol(var_id)) %in% values)
    #print(dim(dataset))
  }
  
  return(dataset)
}



create_return <- function(dataset,res){
#create dataframe with study data
# check if dataset has year variable and if so how its written
if('year' %in% names(dataset)){
  study_names <- paste0(dataset$study,', ', dataset$year)[res$not.na.yivi]
} else if ('Year' %in% names(dataset)){
  study_names <- paste0(dataset$Study,', ', dataset$Year)[res$not.na.yivi]
} else {study_names <- dataset[1,]}
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