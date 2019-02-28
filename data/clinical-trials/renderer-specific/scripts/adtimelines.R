rm(list = ls())
library(dplyr)

### Input data
    dm <- read.csv('../../sdtm/dm.csv', colClasses = 'character')
    ae <- read.csv('../../sdtm/ae.csv', colClasses = 'character')
    cm <- read.csv('../../sdtm/cm.csv', colClasses = 'character')
    sv <- read.csv('../../sdtm/sv.csv', colClasses = 'character')

### Output data
    adtimelines <- dm %>%
        full_join(
            rbind(
                select(dm, USUBJID, RFSTDTC) %>%
                    mutate(
                        DOMAIN = 'Enrollment',
                        SEQ = 1,
                        STDY = 1,
                        ENDY = 1,
                        ENDT = RFSTDTC,
                        ONGO = NA,
                        OFFSET = 0
                    ) %>%
                    rename(
                        STDT = RFSTDTC
                    ) %>%
                    select(USUBJID, DOMAIN, STDT, STDY, ENDT, ENDY, SEQ, ONGO, OFFSET),
                select(ae, USUBJID, AESTDT, AESTDY, AEENDT, AEENDY, AESEQ, AEONGO) %>%
                    mutate(
                        DOMAIN = 'Adverse Events',
                        OFFSET = 1
                    ) %>%
                    rename(
                        STDT = AESTDT,
                        STDY = AESTDY,
                        ENDT = AEENDT,
                        ENDY = AEENDY,
                        SEQ = AESEQ,
                        ONGO = AEONGO
                    ) %>%
                    select(USUBJID, DOMAIN, STDT, STDY, ENDT, ENDY, SEQ, ONGO, OFFSET),
                select(cm, USUBJID, CMSTDT, CMSTDY, CMENDT, CMENDY, CMSEQ, CMONGO) %>%
                    mutate(
                        DOMAIN = 'Concomitant Medications',
                        OFFSET = 2
                    ) %>%
                    rename(
                        STDT = CMSTDT,
                        STDY = CMSTDY,
                        ENDT = CMENDT,
                        ENDY = CMENDY,
                        SEQ = CMSEQ,
                        ONGO = CMONGO
                    ) %>%
                    select(USUBJID, DOMAIN, STDT, STDY, ENDT, ENDY, SEQ, ONGO, OFFSET),
                filter(sv, VISIT == 'Visit 1') %>%
                    mutate(
                        DOMAIN = 'Randomization',
                        SEQ = 1,
                        STDY = SVDY,
                        ENDY = SVDY,
                        ENDT = SVDT,
                        ONGO = NA,
                        OFFSET = 0
                    ) %>%
                    rename(
                        STDT = SVDT
                    ) %>%
                    select(USUBJID, DOMAIN, STDT, STDY, ENDT, ENDY, SEQ, ONGO, OFFSET),
                filter(sv, VISIT == 'End of Study') %>%
                    mutate(
                        DOMAIN = 'Study Completion',
                        SEQ = 1,
                        STDY = SVDY,
                        ENDY = SVDY,
                        ENDT = SVDT,
                        ONGO = NA,
                        OFFSET = 0
                    ) %>%
                    rename(
                        STDT = SVDT
                    ) %>%
                    select(USUBJID, DOMAIN, STDT, STDY, ENDT, ENDY, SEQ, ONGO, OFFSET)
            )
        ) %>%
    mutate(
        TOOLTIP = paste('This mark definitely represents the', DOMAIN, 'domain', sep = ' ')
    ) %>%
    arrange(USUBJID, DOMAIN, SEQ)

### Output data
    write.csv(
        adtimelines,
        '../adtimelines.csv',
        row.names = FALSE,
        na = ''
    )