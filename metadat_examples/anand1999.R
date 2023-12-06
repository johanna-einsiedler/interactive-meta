library(metadat)
library(metafor)
library(hash)
library(jsonlite)


anand1999 <- function(input){
# subset according to control group
if (!any(input$`Additional Medication in the Control Group` =='No')){ # if No Aspirin is not ticked
  # exclude studies where control group doesn't get aspirin
    dat <- dat %>% subset(asp.c!=0)
} 
if (!any(input$`Additional Medication in the Control Group` =='Aspirin')){ # if Aspirin is not ticked
  # exclude studies where controls get aspirin
  dat <- dat %>% subset(asp.c!=1)
}
if(!any(input$Intensity=="High-Intensity OA")){ # if High intesnity OA is not ticked
  # exclude studies with high intesity treatment
  dat <- dat %>% subset(intensity!='high')
}

if(!any(input$Intensity=="Moderate-Intensity OA")){ # if Moderate intensity OA is not ticked
  # exclude studies with moderate intesity treatment
  dat <- dat %>% subset(intensity!='moderate')
}

if(!any(input$Intensity=="Low-Intensity OA")){ # if Moderate intensity OA is not ticked
  # exclude studies with moderate intesity treatment
  dat <- dat %>% subset(intensity!='low')
}

if(!any(input$`Additional Medication in the Treatment Group`=="No")){ # if no additional medication in treatement is not ticked
  # exclude studies with no additional medication
  dat <- dat %>% subset(asp.t!=0)
}

if(!any(input$`Additional Medication in the Treatment Group`=="Aspirin")){ # if aspirin in treatement is not ticked
  # exclude studies with aspirinn in treatment
  dat <- dat %>% subset(asp.t!=1)
}

# filter years
dat <- dat %>% subset(year %in% input$Year)

### Run analysis
res <- rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat,digits=2)

# create dataframe with study data
study_names <- paste0(dat$study,', ', dat$year)
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
#forest(res, atransf=exp, at=log(c(0.05, 0.25, 1, 4)), xlim=c(-16,6),
 #      #ilab=cbind(tpos, tneg, cpos, cneg), ilab.xpos=c(-9.5,-8,-6,-4.5),
  #     cex=0.75, header="Author(s) and Year", mlab="", shade=TRUE)
#op <- par(cex=0.75, font=2)