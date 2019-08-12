library(data.table)
library(tidyverse)
library(lubridate)

# input data
accrualOverTime <- '../../data-cleaning/dashboard-accrual-over-time.csv' %>%
    fread(
        sep = ',',
        na.strings = '',
        colClasses = 'character'
    )

# data manipulation
accrualOverTime1 <- accrualOverTime %>%
    mutate(
        participant_count = as.numeric(participant_count)
    )
overall_targets <- accrualOverTime1 %>%
    filter(
        population == 'Target'
    ) %>%
    group_by(
        population, population_order, population_color, date
    ) %>%
    summarize(
        participant_count = sum(participant_count)
    ) %>%
    mutate(
        `filter:Site` = ''
    )

accrualOverTime_overallTarget <- accrualOverTime1 %>%
    filter(
        population != 'Target'
    ) %>%
    bind_rows(
        overall_targets
    )

# output data
accrualOverTime_overallTarget %>%
    fwrite(
        '../../data-cleaning/dashboard-accrual-over-time-overall-target.csv',
        na = '',
        row.names = FALSE
    )