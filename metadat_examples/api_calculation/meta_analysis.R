library(metadat)
library(metafor)
library(hash)
library(jsonlite)
library(dplyr)
library(netmeta)


initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
script.basename <- dirname(script.name)
utils.name <- file.path(script.basename, "utils.R")
meta_analysis.name  <- file.path(script.basename, "meta_analysis.R")

source(paste0(strsplit(this_file,'/')[[1]][1],'/api_calculation/utils.R'))


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
                 #data = dataset, sm = "OR")
  
  ### Conduct random effects network meta-analysis (NMA)
  ### with placebo as reference
  #net <- netmeta(pw, fixed = FALSE, ref = "plac")
  
 # return(net)
#}

#dat.baker2009

# dat.lehmann2018
f.lehmann2018 <- function(dataset){
  res <- rma(yi, vi, data=dataset, test="knha")
  return(res)
}

#dat.bangertdrowns2004
f.bangertdrowns2004 <- function(dataset){
  res <- rma(yi, vi, data=dataset)
  return(res)
}

# dat.bornmann2007
f.bornmann2007 <- function(dataset){
  
  dataset <- escalc(measure="OR", ai=waward, n1i=wtotal, ci=maward, n2i=mtotal, data=dataset)
  res <- rma.mv(yi, vi, random = ~ 1 | study/obs, data=dataset)
  return(res)
}
  
# dat.craft2003
f.craft2003 <- function(dataset){
  tmp <- rcalc(ri ~ var1 + var2 | study, ni=ni, data=dataset)
  V <- tmp$V
  dat <- tmp$dat
  res <- rma.mv(yi, V, mods = ~ var1.var2 - 1, random = ~ var1.var2 | study, struct="UN", data=dat)
  return(res)
}

#dat.crede2010
f.crede2010 <- function(dataset){
  ### calculate r-to-z transformed correlations and corresponding sampling variances
  dat <- escalc(measure="ZCOR", ri=ri, ni=ni, data=dataset)
  
  ############################################################################
  
  ### meta-analysis for the relationship between attendance and grades
  res <- rma(yi, vi, data=dat, subset=criterion=="grade")
  return(res)
}

#dat.dagostino1998
f.agostino1998 <- function(dataset){
  ### compute log odds ratios and corresponding sampling variances
  dat <- escalc(measure="OR",  ai=xt, ci=xc, n1i=nt, n2i=nc, data=dataset,
                replace=FALSE, add.measure=TRUE, add=1/2, to="all")
  
  ### fit a random-effects model for incremental change in runny nose severity at day 1
  res <- rma(yi, vi, data=dat)
  return(res)
}

#dat.graves2010
f.graves2010 <- function(dataset){
  ### analysis using the Mantel-Haenszel method
  res <- rma.mh(measure="RR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dataset, digits=2)
  return(res)
}

#dat.hannum2020
f.hannum2020 <- function(dataset){
  dat <- escalc(measure="PR", xi=xi, ni=ni, data=dataset)
  res <- rma(yi,vi,data=dat)
  return(res)
}

#dat.hartmannboyce2018
f.hartmannboyce2018 <- function(dataset){
  ### turn treatment into a factor with the desired ordering
  dataset$treatment <- factor(dataset$treatment, levels=unique(dataset$treatment))
  res <- rma.mh(measure="OR", ai=x.nrt,  n1i=n.nrt,
                ci=x.ctrl, n2i=n.ctrl, data=dataset, digits=2)
  return(res)
}

#dat.ishak2007
f.ishak2007 <- function(dataset){
  ### create long format dataset
  dat <- reshape(dataset, direction="long", idvar="study", v.names=c("yi","vi"),
                 varying=list(c(2,4,6,8), c(3,5,7,9)))
  dat <- dat[order(study, time),]
  ### remove missing measurement occasions from dat.long
  dat <- dat[!is.na(yi),]
  rownames(dat) <- NULL
  head(dat, 8)
  
  ### construct the full (block diagonal) V matrix with an AR(1) structure
  ### assuming an autocorrelation of 0.97 as estimated by Ishak et al. (2007)
  V <- vcalc(vi, cluster=study, time1=time, phi=0.97, data=dat)
  ### multivariate model with heteroscedastic AR(1) structure for the true effects
  res <- rma.mv(yi, V, mods = ~ factor(time) - 1, random = ~ time | study,
                struct = "HAR", data = dat)
  return(res)
}
  
  #dat.kalaian1996
f.kalaian1996 <- function(dataset){
  ### construct variance-covariance matrix assuming rho = 0.66 for effect sizes
  ### corresponding to the 'verbal' and 'math' outcome types
  V <- vcalc(vi, cluster=study, type=outcome, data=dataset, rho=0.66)
  
  ### fit multivariate random-effects model
  res <- rma.mv(yi, V, mods = ~ outcome - 1,
                random = ~ outcome | study, struct="UN",
                data=dataset, digits=3)
  return(res)
  
}

#dat.konstantopoulos2011
f.konstantopoulos2011 <- function(dataset){
  res <- rma(yi, vi, data=dataset)
  return(res)
  
}

#dat.mccurdy2020
f.mccurdy2020 <- function(dataset){
  res <- rma.mv(yi, vi, mods = ~ condition,
                random = list(~ 1 | article/experiment/sample/id, ~ 1 | pairing),
                data=dataset, sparse=TRUE, digits=3)
  return(res)
}

#dat.mcdaniel1994
f.mcdaniel1994 <- function(dataset){
  ### calculate r-to-z transformed correlations and corresponding sampling variances
  dat <- escalc(measure="ZCOR", ri=ri, ni=ni, data=dataset)
    ### meta-analysis of the transformed correlations using a random-effects model
  res <- rma(yi, vi, data=dat)
  return(res)
}

f.kearon1998 <- function(dat){
  ### calculate diagnostic log odds ratios and corresponding sampling variances
  dat <- escalc(measure="OR", ai=tp, n1i=np, ci=nn-tn, n2i=nn, data=dat, add=1/2, to="all")
  ### fit random-effects model for the symptomatic patients
  res <- rma(yi, vi, data=dat)
  return(res)
}

f.baskerville2012 <- function(dat){
  res <- rma(smd, sei=se, data=dat, method="DL")
  return(res)
  
}
