library(metadat)
library(metafor)
library(jsonlite)
dat <- dat.lehmann2018
dat_lehmann2018 <- paste0('{"dat.lehmann2018":{ "Publication Status": ["Peer reviewed", "Not peer reviewed"],
  "Publication Venue":', paste0('["',paste(sort(unique(dat$Source_Type)),collapse='","'),'"], \n'),
                               '"Year":', paste0('[',paste(sort(unique(dat$Year)),collapse=','),'], \n'),
                               '"Preregistration": ["Pre-Registered","Not Pre-Registered"],
  "Contrast Colors":', paste0('["',paste(sort(unique(dat$Color_Contrast)),collapse='","'),'"], \n'),
                               '"Color Forms":', paste0('["',paste(sort(unique(dat$Color_Form)),collapse='","'),'"], \n'),
                               '"Photo Types":', paste0('["',paste(sort(unique(dat$Photo_Type)),collapse='","'),'"], \n'),
                               '"Measuring Scale Used":',paste0('["',paste(sort(unique(dat$DV_Type)),collapse='","'),'"], \n'),
                               '"Country":', paste0('["',paste(sort(unique(dat$Location)),collapse='","'),'"], \n'),
                               '"Continent":',paste0('["',paste(sort(unique(dat$Continent)),collapse='","'),'"], \n'),
                               '"Study Population":',paste0('["',paste(sort(unique(dat$Participants)),collapse='","'),'"], \n'),
                               '"Study Design":',paste0('["',paste(sort(unique(dat$Design)),collapse='","'),'"], \n'),
                               '"Participant Ethnitcity":', paste0('["',paste(sort(unique(dat$Eth_Majority)),collapse='","'),'"] \n'),

                               '}') %>%
  str_replace_all("\\\\", "") %>%
  str_replace_all("\n", "")


dat <- dat.anand1999
dat_anand1999 <-  paste0('"dat.anand1999":{
  "Additional Medication in the Control Group": ["No","Aspirin"],
  "Intensity": ["High-Intesity OA","Moderate-Intensity OA","Low Intensity OA"],
  "Additional Medication in the Treatment Group": ["No","Aspirin"],
  "Year":', paste0('[',paste(sort(unique(dat$year)),collapse=','),']'),'
}}') %>%  str_replace_all("\\\\", "") %>%
  str_replace_all("\n", "")

# write json
data <- paste0(dat_lehmann2018,',',dat_anand1999)
write_file(data,'/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/study_info.txt')
write_json(toJSON(data,pretty=TRUE,auto_unbox=TRUE), '/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/study_info.json')


# read in again to check formatting is correct
fromJSON('/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/study_info.txt')
           
           

