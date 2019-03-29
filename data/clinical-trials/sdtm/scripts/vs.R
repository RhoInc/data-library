rm(list = ls())
library(tidyverse)
set.seed(2357)

### Input data
    sv <- read.csv('../sv.csv', colClasses = 'character') %>%
        rename(
            VSDT = SVDT,
            VSDY = SVDY
        ) %>%
        filter(
            SVSTATUS == 'Completed'
        )
    vitals <- read.csv('../../data-dictionaries/vital-signs.csv', colClasses = 'character') %>%
        select(-VSAGELO, -VSAGEHI) %>%
        mutate(one = 1) %>%
        group_by(VSTEST) %>%
        mutate(seq = cumsum(one)) %>%
        filter(row_number() == n()) %>%
        select(-one, -seq) %>%
        ungroup()
    scheduleOfEvents <- read.csv('../../data-dictionaries/schedule-of-events.csv', colClasses = 'character')

### Derive data
    vs <- NULL

    for (i in 1:nrow(sv)) {
        visit <- sv[i,]
        vs_vis <- merge(vitals, visit, all = TRUE)

        for (j in 1:nrow(vs_vis)) {
            VSSTNRLO <- as.numeric(vs_vis[j,'VSSTNRLO'])
            VSSTNRHI <- as.numeric(vs_vis[j,'VSSTNRHI'])
            mean <- (VSSTNRHI + VSSTNRLO)/2
            std <- (VSSTNRHI - VSSTNRLO)/2
            vs_vis[j,'VSSTRESN'] <- ifelse(runif(1) > .02, max(rnorm(1, mean, std), 0), NA)
        }

        vs <- plyr::rbind.fill(vs, vs_vis)
    }

    scheduleOfEvents_vitals <- merge(scheduleOfEvents, vitals, all = TRUE) %>%
        sample_n(nrow(scheduleOfEvents)*nrow(vitals)/10) %>%
        mutate(VISIT_VSTEST = paste(VISIT, VSTEST, sep = '_'))

    vs <- vs %>%
        mutate(
            VSSTRESN = ifelse(
                !paste(VISIT, VSTEST, sep = '_') %in% scheduleOfEvents_vitals$VISIT_VSTEST,
                    VSSTRESN,
                    NA
            )
        ) %>%
        arrange(USUBJID, VISITNUM, VSTEST) %>%
        select(USUBJID, VISIT, VISITNUM, VSDT, VSDY, VSCAT, VSTEST, VSSTRESU, VSSTRESN, VSSTNRLO, VSSTNRHI)

### Output data
    write.csv(
        vs,
        '../vs.csv',
        row.names = FALSE,
        na = ''
    )
