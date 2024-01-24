library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
library(stringr)

# FUNCTION TO FILTER DATAFRAME ACCORDING TO FILTER INPUT
filter_data <- function(dataset, inputs){
  
  # remove [] at beginning and end
  #input <- substring(input,2,nchar(input)-1)
  # split into parts
  #inputs <- strsplit(input, '},')[[1]]
  
  for (i in (1:dim(inputs)[1])){
    # format correctly
    #if (i < length(inputs)){
    input <- inputs[i,]
    # } else { input <- fromJSON(paste0(inputs[i])) }
    
    # filter data
    var_id <- input$id[[1]]
    #print(var_id)
    values <- input$values[[1]]
    if (typeof(values)=='integer'){
      values <- as.list(values)} else {
        values <- as.list(strsplit(values, ',\"'))
      }
    # check if na values are there and replace with true NA
    values[values=='NA']<- NA
    
    # check if we have NAs as this requires special treatment
    if (any(is.na(values))){
      dataset <- dataset %>% filter(eval(as.symbol(var_id)) %in% values | is.na(eval(as.symbol(var_id))))
    } else{
      dataset <- dataset %>% filter(eval(as.symbol(var_id)) %in% values)
      
    }
    
  }
  
  return(dataset)
}


# FUNCTION TO CREATE A NICE RETURN DATAFRAME
create_return <- function(dataset,res){
  

#create dataframe with study data
# check if dataset has year variable and if so how its written
if(('year' %in% names(dataset)) && ('study' %in% names(dataset))){
  study_names <- paste0(dataset$study,', ', dataset$year)[res$not.na]
} else if (('Year' %in% names(dataset)) && ('Study' %in% names(dataset))){
  study_names <- paste0(dataset$Study,', ', dataset$Year)[res$not.na]
} else {study_names <- dataset[,1][res$not.na]}
measure <- exp(res$yi)
#participants <- attr(res$yi, 'ni')
#if (length(participants)!=length(measure)){
 # participants <- participants[dataset$id]
#}
ci_lower <- exp(res$yi -sqrt(res$vi)* qt(0.975, df = participants-1))
ci_upper <- exp(res$yi +sqrt(res$vi)* qt(0.975, df = participants-1))

out <- tibble(study_names, measure, ci_lower, ci_upper)
# add metastudy result
meta <- data.frame(study_names='Random Effects Model',
                   measure=exp(res$beta)[1], 
                   #participants = sum(participants), 
                   ci_lower = exp(res$ci.lb),
                   ci_upper = exp(res$ci.ub))
# create json to export
out <- rbind(out,meta)
out <- out %>% mutate(across(where(is.numeric), \(x) round(x,digits=2)))

out_json <- toJSON(out,pretty=TRUE)


# gather study information
meta_info <- c(measure = unname(res$measure[[1]]),
     call = paste0(trimws(deparse(res$call)),collapse=''),
     method =res$method[[1]],
     ll = res$fit.stats['ll',]['REML'],
     dev = res$fit.stats['dev',]['REML'],
     AIC = res$fit.stats['AIC',]['REML'],
     BIC = res$fit.stats['BIC',]['REML'],
     AICc = res$fit.stats['AICc',]['REML'],
     pval = res$pval,
     zval = res$zval,
     n=res$k,
     QE=res$QE)

  meta_info_json <- toJSON(meta_info,pretty=TRUE)    
     
  return_list <- list(out_json, meta_info_json)     

return(return_list)
}
