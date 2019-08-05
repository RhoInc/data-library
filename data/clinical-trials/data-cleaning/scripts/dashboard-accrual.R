library(data.table)
library(tidyverse)

# input data
dm <- '../../sdtm/dm.csv' %>%
    fread(
        sep = ',',
        na.strings = '',
        colClasses = 'character'
    )
sv <- '../../sdtm/sv.csv' %>%
    fread(
        sep = ',',
        na.strings = '',
        colClasses = 'character'
    )
sites <- '../../data-dictionaries/sites.csv' %>%
    fread(
        sep = ',',
        na.strings = '',
        colClasses = 'character'
    )

# data manipulation

    # screened population
    screened <- dm %>%
        select(
            USUBJID, RFSTDTC
        ) %>%
        rename(
            subjid = USUBJID,
            date = RFSTDTC
        ) %>%
        mutate(
            population = 'Screened',
            population_order = 1,
            population_color = '#a6bddb',
            population_superset = ''
        )

    # randomized popluation
    randomized <- sv %>%
        filter(
            VISIT == 'Visit 1' & SVSTATUS == 'Completed'
        ) %>%
        select(USUBJID, SVDT) %>%
        rename(
            subjid = USUBJID,
            date = SVDT
        ) %>%
        mutate(
            population = 'Randomized',
            population_order = 2,
            population_color = '#3690c0',
            population_superset = 'Screened'
        )

    # stacked, merged with DM, merged with sites
    accrual <- screened %>%
        rbind(randomized) %>%
        left_join(
            dm,
            by = c('subjid' = 'USUBJID')
        ) %>%
        left_join(
            sites,
            by = c('SITEID' = 'site_id')
        ) %>%
        select(
            -SITE, -ARM, -ARMCD, -SBJTSTAT, -RFSTDTC, -RFENDTC, -RFENDY, -SAFFL, -SAFFN
        ) %>%
        rename(
            site_id = SITEID,
            age = AGE,
            sex = SEX,
            race = RACE
        ) %>%
        mutate(
            `filter:Site` = site
        ) %>%
        arrange(
            subjid, population_order
        )

# output data
accrual %>%
    fwrite(
        '../../data-cleaning/dashboard-accrual.csv',
        na = '',
        row.names = FALSE
    )