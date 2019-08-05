library(data.table)
library(tidyverse)

# input data
dm <- '../../sdtm/dm.csv' %>%
    fread(
        sep = ',',
        na.strings = '',
        colClasses = 'character'
    )

# data manipulation
sites <- dm %>%
    select(SITE, SITEID, RFSTDTC, RFENDTC, SAFFL) %>%
    group_by(SITE, SITEID) %>%
    summarize(
        activation_date = min(as.Date(RFSTDTC, '%Y-%m-%d')),
        completion_date = max(as.Date(RFSTDTC, '%Y-%m-%d')),
        accrual_duration = as.numeric(completion_date - activation_date),

        # actual accrual
        accrual = sum(SAFFL == 'Y'),
        accrual_rate_days = accrual/accrual_duration,
        accrual_rate_weeks = accrual_rate_days*7,
        accrual_rate_months = accrual_rate_days*30.4375,

        # target accrual
        target = 30,
        target_rate_days = target/accrual_duration,
        target_rate_weeks = target_rate_days*7,
        target_rate_months = target_rate_days*30.4375,

        percent_accrued = accrual/target*100
    ) %>%
    ungroup() %>%
    mutate(
        site = paste0('Clinical ', SITE),
        site_info = paste(
            site,
            paste0('Activation date: ', as.character(activation_date)),
            paste0('Accrual: ', as.character(accrual), ' participants'),
            paste0('Target: ', as.character(target), ' participants'),
            paste0('Accrual rate: ', as.character(round(accrual_rate_months, 1)), ' participants/month'),
            paste0('Target rate: ', as.character(round(target_rate_months, 1)), ' participants/month'),
            paste0('Accrued of target: ', round(percent_accrued, 0), '%'),
            sep = '\n'
        )
    ) %>%
    rename(
        site_abbreviation = SITE,
        site_id = SITEID,
        accrual_rate = accrual_rate_months,
        target_rate = target_rate_months
    ) %>%
    select(site, site_id, site_abbreviation, site_info, activation_date, completion_date, accrual_duration, accrual, accrual_rate, target, target_rate, percent_accrued)

# output data
sites %>%
    fwrite(
        '../sites.csv',
        na = '',
        row.names = FALSE
    )