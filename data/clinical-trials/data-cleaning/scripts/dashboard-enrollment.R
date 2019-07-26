
library(tidyverse)

sites <- c("Clinical Site 1","Clinical Site 2","Clinical Site 3","Clinical Site 4","Clinical Site 5")

site_values <- sample(sites, 80, replace=TRUE, prob=c(0.12, 0.12, 0.16, .3, .3)) 

site_short_values <- substr(site_values,10,15)

data <- data.frame(site=site_values, site_short = site_short_values)

# Add subjid
for (i in 1:nlevels(data$site)) {
  
  site_level <- levels(data$site)[i]
  subj_count = 0
  for(j in 1:nrow(data[data$site == site_level,])){

    
    if (j %% 2 == 0)  {
      trt <- sample(c("TRTA","TRTB"), 1, replace=TRUE, prob=c(.5, .5)) 
      
      cohort <- sample(c("Cohort 1","Cohort 2"), 1, replace=TRUE, prob=c(.6, .4)) 
      
      subj_count = subj_count + 1
      
    } else if (rbinom(n=1, size=1, prob=0.8) == c(1)) {
      trt <- sample(c("TRTA","TRTB"), 1, replace=TRUE, prob=c(.5, .5)) 
      
      cohort <- sample(c("Cohort 1","Cohort 2"), 1, replace=TRUE, prob=c(.6, .4)) 
      
      subj_count = subj_count + 1
    }
      data[data$site == site_level,"subjid"][j] <- paste0("0",i,"-00",subj_count)
      data[data$site == site_level,"filter:Treatment Group"][j] <- trt
      data[data$site == site_level,"filter:Cohort"][j] <- cohort
    }
      
  }

data$population <- "Screened"

data$population_superset <- ""

data[duplicated(data$subjid),"population"] <- "Randomized"

data[duplicated(data$subjid),"population_superset"] <- "Screened"

# I wanted to see how far I could get without tidyverse but I throw in the towel here

data <- data %>%
  mutate(population_order = ifelse(population == "Screened", 1, 2) ) %>%
  mutate(population_color = ifelse(population == "Screened", "#a6bddb", "#3690c0") )

write.csv(data, '../dashboard-enrollment.csv')
