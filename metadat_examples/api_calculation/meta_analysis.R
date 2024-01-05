library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
library(netmeta)
source('utils.R')


# dat.aloe2013
f.aloe2013 <- function(dataset){
  
  ### compute the partial correlation coefficients and corresponding sampling variances
  dat <- escalc(measure="PCOR", ti=tval, ni=n, mi=preds, data=dataset)
  
  res <-rma(yi, vi, data=dat)
  return(res)
}


# dat.anand1999
f.anand1999<- function(dataset){
  res <- rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dataset,digits=2)
  return(res)
}

# dat.assink2016
f.assink2016<- function(dataset){
  res <- rma.mv(yi, vi, random = ~ 1 | study/esid, data=dataset)
  return(res)
}


# dat.axfors2021
f.axfors2021 <- function(dataset){
  # calculate log odds ratios and corresponding sampling variances
  dat <- escalc(measure="OR", ai=hcq_arm_event, n1i=hcq_arm_total,
                ci=control_arm_event, n2i=control_arm_total, data=dataset)
  res <- rma(yi, vi,  slab = id, data=dat)
  return(res)
}

#dat.bakdash2021
f.bakdash2021 <- function(dataset){
  ### multilevel meta-analytic model to get the overall pooled effect
  res <- rma.mv(es.z, vi.z, mods = ~ 1,
                        random = ~ 1 | SampleID / Outcome,
                        data = dataset,
                        test = "t")
  return(res)
}

# dat.baker2009
#f.baker2009 <- function(dataset){
  ### Transform data from long arm-based format to contrast-based
  ### format. Argument 'sm' has to be used for odds ratio as summary
  ### measure; by default the risk ratio is used in the metabin function
  ### called internally.
 # pw <- pairwise(treatment, exac, total, studlab = paste(study, year),
                 data = dataset, sm = "OR")
  
  ### Conduct random effects network meta-analysis (NMA)
  ### with placebo as reference
  #net <- netmeta(pw, fixed = FALSE, ref = "plac")
  
 # return(net)
#}

# dat.lehmann2018
f.lehmann2018 <- function(dataset){
  res <- rma(yi, vi, data=dataset, test="knha")
  return(res)
}

#dat.bangertdrowns2004
f.bangertdrowns2004 <- function(dataset){
  res <- rma(yi, vi, data=dat)
  return(res)
}