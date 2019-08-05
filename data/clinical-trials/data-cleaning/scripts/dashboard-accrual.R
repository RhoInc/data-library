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
        population_superset = ''
    )
accrual <- screened %>%
    rbind(randomized) %>%
    left_join(
        dm,
        by = c('subjid' = 'USUBJID')
    ) %>%
    left_join(
        sites,
        by = c('SITEID' = 'site_id')
    )