rm(list = ls())
library(dplyr)

### Input data
    lb <- read.csv('../../sdtm/lb.csv', colClasses = 'character')
    vs <- read.csv('../../sdtm/vs.csv', colClasses = 'character')
    dm <- read.csv('../../sdtm/dm.csv', colClasses = 'character')

### Derive data
    names(lb) <- sapply(names(lb), function(name) {
        if (grepl('LB', name))
            return(substring(name, 3))
        else
            return(name)
    })
    names(vs) <- sapply(names(vs), function(name) {
        if (grepl('VS', name))
            return(substring(name, 3))
        else
            return(name)
    })
    lb_vs <- plyr::rbind.fill(lb,vs) %>%
        mutate(VISITN = VISITNUM)
    adbds <- full_join(dm, lb_vs) %>%
        arrange(USUBJID, VISITN, CAT, TEST
    )

### Output data
    write.csv(
        adbds,
        '../adbds.csv',
        row.names = FALSE,
        na = ''
    )
