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
            dm %>% select(USUBJID, SITEID, AGE, SEX, RACE, ARM),
            by = c('subjid' = 'USUBJID')
        ) %>%
        left_join(
            sites %>% select(site, site_id, site_abbreviation, site_info),
            by = c('SITEID' = 'site_id')
        ) %>%
        select(
            subjid, population, population_order, population_color, population_superset, date, site, site_abbreviation, site_info, ARM, AGE, SEX, RACE
        ) %>%
        rename(
            `filter:Arm` = ARM,
            `listing:Age` = AGE,
            `listing:Sex` = SEX,
            `listing:Race` = RACE
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