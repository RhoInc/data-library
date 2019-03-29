rm(list = ls())
library(tidyverse)
set.seed(2357)

### Input data
    dm <- read.csv('../dm.csv', colClasses = 'character') %>% select(USUBJID, SAFFL, RFSTDTC)
    medications <- read.csv('../../data-dictionaries/medications.csv', colClasses = 'character')

### Derive data
    cm <- NULL
    cm_sample <- 0:5

    CMSTDY <- 1:365

    CMDOSE <- c(1,2,3,4,5)
    CMDOSE_probs <- c(.2,.2,.2,.2,.2)

    CMROUTE <- c('orally', 'intravenously', 'subcutaneously', 'sublingually', 'topically')
    CMROUTE_probs <- c(.6, .1, .1, .1, .1)

    CMONGO <- c('N', 'Y')
    CMONGOprobs <- c(.5, .5)

    for (i in 1:nrow(dm)) {
        id <- dm[i,]
        id$nmedications <- sample(cm_sample, 1)

        if (id$nmedications & id$SAFFL == 'Y') {
            sampledmedications <- medications[sample(nrow(medications), id$nmedications),]

            for (j in 1:nrow(sampledmedications)) {
                sampledmedications[j,'CMSTDY'] = sample(CMSTDY, 1)
                sampledmedications[j,'CMENDY'] = ifelse(sampledmedications[j,'CMSTDY'] < 365,
                    sample(sampledmedications[j,'CMSTDY']:365, 1),
                    365)
                sampledmedications[j,'CMINDC'] = "I'm not a doctor, I'm a data guru."
                sampledmedications[j,'CMDOSE'] = sample(CMDOSE, 1, prob = CMDOSE_probs)
                sampledmedications[j,'CMROUTE'] = sample(CMROUTE, 1, prob = CMROUTE_probs)
                sampledmedications[j,'CMONGO'] = sample(CMONGO, 1, prob = CMONGOprobs)
            }

            cm <- plyr::rbind.fill(cm, merge(id, sampledmedications, all = TRUE))
        }
    }

    cm <- cm %>%
        arrange(USUBJID, CMSTDY, CMENDY, CMTRT) %>%
        mutate(
            CMSTDT = as.Date(RFSTDTC) + CMSTDY - 1,
            CMENDT = as.Date(RFSTDTC) + CMENDY - 1,
            one = 1
        ) %>%
        select(-SAFFL, -RFSTDTC, -nmedications) %>%
        group_by(USUBJID) %>%
        mutate(CMSEQ = cumsum(one)) %>%
        ungroup() %>%
        select(USUBJID, CMSEQ, CMSTDT, CMSTDY, CMENDT, CMENDY, CMTRT, PREFTERM, ATCTEXT2, CMONGO, CMDOSE, CMROUTE, CMINDC)

### Output data
    write.csv(
        cm,
        '../cm.csv',
        row.names = FALSE,
        na = ''
    )
