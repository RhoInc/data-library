rm(list = ls())
library(dplyr)

### Input data
    adsl <- read.csv('../adsl.csv', colClasses = 'character')
    vs <- read.csv('../../sdtm/vs.csv', colClasses = 'character')

### Derive data
    advs <- vs %>%
        left_join(adsl) %>%
        rename(
            PARAMCAT = VSCAT,
            AVISIT = VISIT,
            AVISITN = VISITNUM,
            AVAL = VSSTRESN,
            ANRLO = VSSTNRLO,
            ANRHI = VSSTNRHI,
            ADT = VSDT,
            ADY = VSDY
        ) %>%
        mutate(
            PARAM = ifelse(
                VSSTRESU != '',
                    paste0(VSTEST, ' (', VSSTRESU, ')'),
                    VSTEST
            )
        ) %>%
        select(names(adsl), AVISIT, AVISITN, ADT, ADY, PARAMCAT, PARAM, AVAL, ANRLO, ANRHI) %>%
        arrange(USUBJID, AVISITN, PARAMCAT, PARAM)

### Output data
    write.csv(
        advs,
        '../advs.csv',
        row.names = FALSE,
        na = ''
    )