rm(list = ls())
library(tidyverse)
set.seed(2357)

### Input data
    dm <- read.csv('../dm.csv', colClasses = 'character') %>% select(USUBJID, SAFFL, RFSTDTC)
    adverseEvents <- read.csv('../../source/adverse-events.csv', colClasses = 'character')

### Derive data
    ae <- NULL
    ae_sample <- 0:5

    AESTDY <- 1:365

    AESER <- c('N', 'Y')
    AESER_probs <- c(.9, .1)

    AESEV <- c('MILD', 'MODERATE', 'SEVERE')
    AESEV_probs <- c(.6, .3, .1)

    AEREL <- c('NOT RELATED', 'UNLIKELY RELATED', 'POSSIBLY RELATED', 'PROBABLY RELATED', 'DEFINITELY RELATED')
    AEREL_probs <- c(.3, .25, .2, .15, .1)

    AEOUT <- c('RECOVERED', 'RESOLVED, RECOVERED', 'RESOLVED WITHOUT SEQUELAE', 'RESOLVED WITH SEQUELAE')
    AEOUT_probs <- c(.4, .3, .2, .1)

    AEONGO <- c('N', 'Y')
    AEONGO_probs <- c(.5, .5)

    for (i in 1:nrow(dm)) {
        id <- dm[i,]
        id$nadverseEvents <- sample(ae_sample, 1)

        if (id$nadverseEvents & id$SAFFL == 'Y') {
            sampledadverseEvents <- adverseEvents[sample(nrow(adverseEvents), id$nadverseEvents),]

            for (j in 1:nrow(sampledadverseEvents)) {
                sampledadverseEvents[j,'AESTDY'] = sample(AESTDY, 1)
                sampledadverseEvents[j,'AEENDY'] = ifelse(sampledadverseEvents[j,'AESTDY'] < 365,
                    sample(sampledadverseEvents[j,'AESTDY']:365, 1),
                    365)
                sampledadverseEvents[j,'AESER'] = sample(AESER, 1, prob = AESER_probs)
                sampledadverseEvents[j,'AESEV'] = sample(AESEV, 1, prob = AESEV_probs)
                sampledadverseEvents[j,'AEREL'] = sample(AEREL, 1, prob = AEREL_probs)
                sampledadverseEvents[j,'AEOUT'] = sample(AEOUT, 1, prob = AEOUT_probs)
                sampledadverseEvents[j,'AEONGO'] = sample(AEONGO, 1, prob = AEONGO_probs)
            }

            ae <- plyr::rbind.fill(ae, merge(id, sampledadverseEvents, all = TRUE))
        }
    }

    ae <- ae %>%
        arrange(USUBJID, AESTDY, AEENDY, AETERM) %>%
        mutate(
            AESTDT = as.Date(RFSTDTC) + AESTDY - 1,
            AEENDT = as.Date(RFSTDTC) + AEENDY - 1,
            one = 1
        ) %>%
        select(-SAFFL, -RFSTDTC, -nadverseEvents) %>%
        group_by(USUBJID) %>%
        mutate(AESEQ = cumsum(one)) %>%
        ungroup() %>%
        select(USUBJID, AESEQ, AESTDT, AESTDY, AEENDT, AEENDY, AETERM, AEDECOD, AEBODSYS, AESER, AEONGO, AESEV, AEREL, AEOUT)

### Output data
    write.csv(
        ae,
        '../ae.csv',
        row.names = FALSE,
        na = ''
    )