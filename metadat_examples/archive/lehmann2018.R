library(metadat)
library(metafor)
library(hash)
library(jsonlite)

lehmann2018 <- function(input){
if (!any(input$`Publication Status`=='Peer reviewed')){ # if peer reviewed is not ticked
  dat <- dat %>% subset(PRPublication!='Yes') # exclude studies with yes
}

if (!any(input$`Publication Status`=='Not peer reviewed')){ # if not peer reviewed is not ticked
  dat <- dat %>% subset(PRPublication!='No') # exclude non per reviewed
}

if(!any(input$`Preregistration`=='Prergistered')){ # if Preregistered is not ticked
  dat <- dat %>% subset(Preregistered!='Pre-Registered') # exclude pre registered
}
if(!any(input$`Preregistration`=='Not Prergistered')){ # if Not Preregistered is not ticked
  dat <- dat %>% subset(Preregistered!='Not Pre-Registered') # exclude  not pre registered
}

# subset year
dat <- dat %>% subset(Year %in% input$`Year`)

# subset publication venue
dat <- dat %>% subset(Source_Type %in% input$`Publiation Venue`)

# subset contrast colors
dat <- dat %>% subset(Color_Contrast %in% input$`Contrast Colors`)

# subset color forms
dat <- dat %>% subset(Color_Form %in% input$`Color Forms`)

# Photo Types
dat <- dat %>% subset(Photo_Type %in% input$`Photo Types`)

# filter measuring scales
dat <- dat %>% subset(DV_Type %in% input$`Measuring Scale Used`)

# filter country
dat <- dat %>% subset(Location %in% input$Country)

# filter continent
dat <- dat %>% subset(Continent %in% input$Continent)

# filter study population
dat <- dat %>% subset(Participants %in% input$`Study Population`)

# filter study design
dat <- dat %>% subset(Design %in% input$`Study Design`)

# filter ethnicity
dat <- dat %>% subset(Eth_Majority %in% input$`Participant Ethnicity`)

# filter shade of red
#dat <- dat %>% subset(Color_Red %in% input$`Shade of Red`)

# filtr control colors
#dat <- dat %>% subset(Color_Control %in% input$`Control Colors`)

# run analysis
res <- rma(yi, vi, data=dat, test="knha")


# create dataframe with study data
study_names <- paste0(dat$Short_Title,', ', dat$Year)
measure <- exp(res$yi)
participants <- dat$Total.SampleSize
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
}





