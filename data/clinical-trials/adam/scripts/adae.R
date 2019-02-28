rm(list = ls())
library(dplyr)

### Input data
    dm <- read.csv('../../sdtm/dm.csv', colClasses = 'character')
    ae <- read.csv('../../sdtm/ae.csv', colClasses = 'character')

### Derive data
    adae <- full_join(dm, ae) %>%
        arrange(USUBJID, AESEQ) %>%
        rename(
            ASEQ = AESEQ,
            ASTDT = AESTDT,
            ASTDY = AESTDY,
            AENDT = AEENDT,
            AENDY = AEENDY
        ) %>%
        mutate(
            AESEQ = ASEQ
        )

### Output data
    write.csv(
        adae,
        '../adae.csv',
        row.names = FALSE,
        na = ''
    )