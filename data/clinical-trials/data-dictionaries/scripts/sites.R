library(data.table)
library(tidyverse)
library(lubridate)

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

# data manipulation
randomized <- sv %>%
    filter(
        VISIT == 'Visit 1' & SVSTATUS == 'Completed'
    )
snapshot_date <- max(ymd(randomized$SVDT))

sites <- dm %>%
    select(
        SITE, SITEID, RFSTDTC, RFENDTC, SAFFL
    ) %>%
    group_by(
        SITE, SITEID
    ) %>%
    summarize(
        site_accrual_start_date = min(as.Date(RFSTDTC, '%Y-%m-%d')) - 5,
        site_accrual_end_date = max(as.Date(RFSTDTC, '%Y-%m-%d')) + 5,
        site_accrual_duration = as.numeric(site_accrual_end_date - site_accrual_start_date),

        # actual accrual
        site_accrual = sum(SAFFL == 'Y'),
        site_accrual_rate_days = site_accrual/site_accrual_duration,
        site_accrual_rate_weeks = site_accrual_rate_days*7,
        site_accrual_rate_months = site_accrual_rate_days*30.4375,

        # target accrual
        site_target = 30,
        site_target_rate_days = site_target/site_accrual_duration,
        site_target_rate_weeks = site_target_rate_days*7,
        site_target_rate_months = site_target_rate_days*30.4375,

        site_percent_accrued = site_accrual/site_target*100
    ) %>%
    ungroup %>%
    mutate(
        accrual_start_date = min(site_accrual_start_date),
        accrual_end_date = snapshot_date,
        accrual_duration = as.numeric(accrual_end_date - accrual_start_date),

        # actual accrual
        accrual = sum(site_accrual),
        accrual_rate_days = accrual/accrual_duration,
        accrual_rate_weeks = accrual_rate_days*7,
        accrual_rate_months = accrual_rate_days*30.4375,

        # target accrual
        target = sum(site_target),
        target_rate_days = target/accrual_duration,
        target_rate_weeks = target_rate_days*7,
        target_rate_months = target_rate_days*30.4375,

        percent_accrued = accrual/target*100,

        site = SITE,
        site_abbreviation = sub('Clinical ', '', SITE),
        site_info = paste(
            site,
            paste0('Activation date: ', as.character(site_accrual_start_date)),
            paste0('Accrual: ', as.character(site_accrual), ' participants'),
            paste0('Target: ', as.character(site_target), ' participants'),
            paste0('Accrual rate: ', as.character(round(site_accrual_rate_months, 1)), ' participants/month'),
            paste0('Target rate: ', as.character(round(site_target_rate_months, 1)), ' participants/month'),
            paste0('Accrued of target: ', round(site_percent_accrued, 0), '%'),
            sep = '\n'
        )
    ) %>%
    rename(
        site_id = SITEID,
        site_accrual_rate = site_accrual_rate_months,
        site_target_rate = site_target_rate_months,
        accrual_rate = accrual_rate_months,
        target_rate = target_rate_months
    ) %>%
    select(
        site, site_id, site_abbreviation, site_info,
        site_accrual_start_date, site_accrual_end_date, site_accrual_duration, site_accrual, site_accrual_rate, site_target, site_target_rate, site_percent_accrued,
             accrual_start_date,      accrual_end_date,      accrual_duration,      accrual,      accrual_rate,      target,      target_rate,      percent_accrued
    )

# output data
sites %>%
    fwrite(
        '../../data-dictionaries/sites.csv',
        na = '',
        row.names = FALSE
    )