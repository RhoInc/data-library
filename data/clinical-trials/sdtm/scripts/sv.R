rm(list = ls())
library(tidyverse)
set.seed(2357)

### Input data
    dm <- read.csv('../dm.csv', colClasses = 'character') %>%
        select(USUBJID, SBJTSTAT, RFSTDTC, RFENDTC, RFENDY, SAFFL)
    dm$participant_deviate <- runif(nrow(dm))
    scheduleOfEvents <- read.csv('../../data-dictionaries/schedule-of-events.csv', colClasses = 'character')

### Derive data
    sv <- NULL

    for (i in 1:nrow(dm)) {
        id <- dm[i,]
        sampledDays <- scheduleOfEvents

        for (j in 1:nrow(scheduleOfEvents)) {
            STDY <- scheduleOfEvents[j,'STDY']
            ENDY <- scheduleOfEvents[j,'ENDY']
            sampledDays[j,'SVDY'] <- sample(STDY:ENDY, 1)
        }

        sv <- sv %>%
            plyr::rbind.fill(
                merge(
                    id,
                    select(sampledDays, VISITNUM, VISIT, SVDY),
                    all = TRUE
                )
            ) %>%
            filter(
                !(SBJTSTAT == 'Screen Failure' & as.numeric(VISITNUM) > 0)
            )
    }

  # Sample data and change to unscheduled visits.
    unscheduledVisitSample <- filter(sv, VISITNUM != '7')
    unscheduledVisits = sample_n(unscheduledVisitSample, nrow(unscheduledVisitSample)/10, T) %>%
        arrange(USUBJID, VISITNUM) %>%
        group_by(USUBJID, VISITNUM) %>%
        mutate(n = row_number()) %>%
        ungroup() %>%
        mutate(
            VISITNUM = paste0(VISITNUM, '.', n),
            VISIT = paste('Unscheduled', VISITNUM, sep = ' '),
            SVDY = SVDY + n*7 + 1
        ) %>%
        select(-n)
    
  # Sample end of study visits and change to early termination visits.
    earlyTerminators <- sv %>%
        filter(SBJTSTAT == 'Early Termination' & VISITNUM == '7') %>%
        mutate(
            VISITNUM = '6.9',
            VISIT = 'Early Termination',
            SVDY = as.Date(RFENDTC) - as.Date(RFSTDTC) + 1
        )

    sv1 <- sv %>%
        rbind(unscheduledVisits) %>%
        rbind(earlyTerminators) %>%
        arrange(USUBJID, VISITNUM) %>%
        mutate(
            SVDT = as.Date(RFSTDTC) + SVDY - 1
        )
    sv2 <- sv1 %>%
        mutate(
            visit_deviate = runif(nrow(sv1)),
            SVSTATUS = case_when(
                SBJTSTAT == 'Screen Failure' ~ 'Failed',
                SBJTSTAT == 'Early Termination' & as.numeric(SVDY) > as.numeric(RFENDY) ~ 'Terminated',
                SBJTSTAT == 'Ongoing' & as.numeric(SVDY) > as.numeric(RFENDY) ~ 'Expected',
                !grepl('screening|unscheduled', VISIT, T) & SBJTSTAT == 'Ongoing' & as.numeric(RFENDY) - as.numeric(SVDY) < 60 & participant_deviate < .5 ~ 'Overdue',
                !grepl('screening|unscheduled', VISIT, T) & visit_deviate < .1 ~ 'Missed',
                TRUE ~ 'Completed'
            )
        ) %>%
        select(USUBJID, VISIT, VISITNUM, SVDT, SVDY, SVSTATUS)
print(table(sv2$SVSTATUS))
overdue <- table(filter(sv2, SVSTATUS == 'Overdue')$USUBJID)
print(overdue)
### Output data
    write.csv(
        sv2,
        '../sv.csv',
        row.names = FALSE,
        na = ''
    )
