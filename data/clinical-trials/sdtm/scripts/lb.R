rm(list = ls())
library(tidyverse)
set.seed(2357)

### Input data
    sv <- read.csv('../sv.csv', colClasses = 'character') %>%
        rename(
            LBDT = SVDT,
            LBDY = SVDY
        ) %>%
        filter(
            SVSTATUS == 'Completed'
        )
    labs <- read.csv('../../source/labs.csv', colClasses = 'character') %>% select(-SEX)
    scheduleOfEvents <- read.csv('../../source/schedule-of-events.csv', colClasses = 'character')

### Output data
    lb <- NULL

    for (i in 1:nrow(sv)) {
        visit <- sv[i,]
        lb_vis <- merge(labs, visit, all = TRUE)

        for (j in 1:nrow(lb_vis)) {
            LBSTNRLO <- as.numeric(lb_vis[j,'LBSTNRLO'])
            LBSTNRHI <- as.numeric(lb_vis[j,'LBSTNRHI'])
            mean <- (LBSTNRHI + LBSTNRLO)/2
            std <- (LBSTNRHI - LBSTNRLO)/2
            lb_vis[j,'LBSTRESN'] <- ifelse(runif(1) > .02, max(rnorm(1, mean, std), 0), NA)
        }

        lb <- plyr::rbind.fill(lb, lb_vis)
    }

    scheduleOfEvents_labs <- merge(scheduleOfEvents, labs, all = TRUE) %>%
        sample_n(nrow(scheduleOfEvents)*nrow(labs)/10) %>%
        mutate(VISIT_LBTEST = paste(VISIT, LBTEST, sep = '_'))

    lb <- lb %>%
        mutate(
            LBSTRESN = ifelse(
                !paste(VISIT, LBTEST, sep = '_') %in% scheduleOfEvents_labs$VISIT_LBTEST,
                    LBSTRESN,
                    NA
            )
        ) %>%
        arrange(USUBJID, VISITNUM, LBTEST) %>%
        select(USUBJID, VISIT, VISITNUM, LBDT, LBDY, LBCAT, LBTEST, LBSTRESU, LBSTRESN, LBSTNRLO, LBSTNRHI)

### Output data
    write.csv(
        lb,
        '../lb.csv',
        row.names = FALSE,
        na = ''
    )