rm(list = ls())
library(dplyr)

### Input data
    adsl <- read.csv('../adsl.csv', colClasses = 'character')
    lb <- read.csv('../../sdtm/lb.csv', colClasses = 'character')

### Derive data
    adlb <- lb %>%
        left_join(adsl) %>%
        rename(
            PARAMCAT = LBCAT,
            AVISIT = VISIT,
            AVISITN = VISITNUM,
            AVAL = LBSTRESN,
            ANRLO = LBSTNRLO,
            ANRHI = LBSTNRHI,
            ADT = LBDT,
            ADY = LBDY
        ) %>%
        mutate(
            PARAM = ifelse(
                LBSTRESU != '',
                    paste0(LBTEST, ' (', LBSTRESU, ')'),
                    LBTEST
            )
        ) %>%
        select(names(adsl), AVISIT, AVISITN, ADT, ADY, PARAMCAT, PARAM, AVAL, ANRLO, ANRHI) %>%
        arrange(USUBJID, AVISITN, PARAMCAT, PARAM)

### Output data
    write.csv(
        adlb,
        '../adlb.csv',
        row.names = FALSE,
        na = ''
    )