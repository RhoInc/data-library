rm(list = ls())
library(dplyr)

### Input data
    dm <- read.csv('../../sdtm/dm.csv', colClasses = 'character')
    cm <- read.csv('../../sdtm/cm.csv', colClasses = 'character')

### Output data
    adcm <- full_join(dm, cm) %>%
        arrange(USUBJID, CMSEQ) %>%
        rename(
            ASEQ = CMSEQ,
            ASTDT = CMSTDT,
            ASTDY = CMSTDY,
            AENDT = CMENDT,
            AENDY = CMENDY
        ) %>%
        mutate(
            CMSEQ = ASEQ
        )

### Output data
    write.csv(
        adcm,
        '../adcm.csv',
        row.names = FALSE,
        na = ''
    )