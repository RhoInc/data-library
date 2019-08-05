library(data.table)
library(tidyverse)
library(lubridate)

# input data
accrual <- '../dashboard-accrual.csv' %>%
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

    # target
    target <- sites %>%
        mutate(
            population = 'Target',
            population_order = 3,
            population_color = '#034e7b',
            population_superset = '',
            target_rate = as.numeric(site_target)/as.numeric(site_accrual_duration)
        ) %>%
        group_by(
            population, population_order, population_color, population_superset, site, site_id, site_abbreviation, site_activation_date, site_completion_date, target_rate
        ) %>%
        do(data.frame(
            date = seq(ymd(.$site_activation_date), ymd(.$site_completion_date), by = '1 day'),
            stringsAsFactors = FALSE
        )) %>%
        mutate(
            participant_count = cumsum(target_rate)
        ) %>%
        ungroup() %>%
        select(
            -site_activation_date, -site_completion_date, -target_rate
        ) %>%
        mutate(
            date = as.character(date)
        )

    # screened and randomized
    shell <- target %>%
        select(
            -starts_with('population'), -participant_count
        )

        # screened
        screened <- accrual %>%
            filter(
                population == 'Screened'
            ) %>%
            select(
                starts_with('population')
            ) %>%
            unique
        screened1 <- shell %>%
            mutate(
                population = rep(screened$population, nrow(shell)),
                population_order = rep(screened$population_order, nrow(shell)),
                population_color = rep(screened$population_color, nrow(shell)),
                population_superset = rep(screened$population_superset, nrow(shell))
            )

        # randomized
        randomized <- accrual %>%
            filter(
                population == 'Randomized'
            ) %>%
            select(
                starts_with('population')
            ) %>%
            unique
        randomized1 <- shell %>%
            mutate(
                population = rep(randomized$population, nrow(shell)),
                population_order = rep(randomized$population_order, nrow(shell)),
                population_color = rep(randomized$population_color, nrow(shell)),
                population_superset = rep(randomized$population_superset, nrow(shell))
            )

    # count participants by date, population, and site
    participant_counts <- accrual %>%
        group_by(
            date, population, population_order, population_color, population_superset, site, site_id, site_abbreviation
        ) %>%
        summarize(
            participant_count = n()
        ) %>%
        ungroup()

    # merge population shells with participant counts
    accrualOverTime <- screened1 %>%
        rbind(randomized1) %>%
        left_join(
            participant_counts
        ) %>%
        mutate(
            participant_count = ifelse(
                is.na(participant_count),
                0,
                participant_count
            )
        ) %>%
        group_by(
            population, population_order, population_color, population_superset, site, site_id, site_abbreviation
        ) %>%
        mutate(
            participant_count = cumsum(participant_count) # cumulatively sum participant counts by population and site
        ) %>%
        ungroup() %>%
        rbind(target) %>%
        arrange(site_id, date, population_order)

# output data
accrualOverTime %>%
    fwrite(
        '../../data-cleaning/dashboard-accrual-over-time.csv',
        na = '',
        row.names = FALSE
    )