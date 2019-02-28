rm(list = ls())
library(dplyr)

### Input data
    dm <- read.csv('../../sdtm/dm.csv', colClasses = 'character')
    sv <- read.csv('../../sdtm/sv.csv', colClasses = 'character')
    ae <- read.csv('../../sdtm/ae.csv', colClasses = 'character')
    cm <- read.csv('../../sdtm/cm.csv', colClasses = 'character')

### Derive data
    adsl <- dm %>%
        left_join(
            sv %>%
                filter(VISIT == 'Visit 1') %>%
                select(USUBJID, SVDT, SVDY) %>%
                rename(
                    RANDDT = SVDT,
                    RANDDY = SVDY
                )
        ) %>%
        left_join(
            sv %>%
                filter(VISIT == 'End of Study') %>%
                select(USUBJID, SVDT, SVDY) %>%
                rename(
                    COMPLDT = SVDT,
                    COMPLDY = SVDY
                )
        ) %>%
        left_join(
            ae %>%
                select(USUBJID) %>%
                distinct() %>%
                mutate(ANYAEFL = 'Y')
        ) %>%
        left_join(
            cm %>%
                select(USUBJID) %>%
                distinct() %>%
                mutate(ANYCMFL = 'Y')
        ) %>%
        mutate(
            ANYAEFL = ifelse(is.na(ANYAEFL), 'N', 'Y'),
            ANYCMFL = ifelse(is.na(ANYCMFL), 'N', 'Y')
        ) %>%
        arrange(USUBJID)

### Output data
    write.csv(
        adsl,
        '../adsl.csv',
        row.names = FALSE,
        na = ''
    )