rm(list = ls())
library(tidyverse)
set.seed(2357)

### Input data
    dm <- read.csv('../../sdtm/dm.csv', colClasses = 'character')
    sv <- read.csv('../../sdtm/sv.csv', colClasses = 'character')
    scheduleOfEvents <- read.csv('../../data-dictionaries/schedule-of-events.csv', colClasses = 'character')

### Encodings
    visit_metadata <- list(
        list(
            status = 'Completed',
            order = 1,
            status_color = '#4daf4a',
            description = 'Visit entered into EDC system'
        ),
        list(
            status = 'Expected',
            order = 2,
            status_color = '#377eb8',
            description = 'Visit expected in the future'
        ),
        list(
            status = 'Overdue',
            order = 3,
            status_color = '#ff7f00',
            description = 'Visit due but not entered into EDC system'
        ),
        list(
            status = 'Missed',
            order = 4,
            status_color = '#e41a1c',
            description = 'Visit missed'
        ),
        list(
            status = 'Terminated',
            order = 5,
            status_color = '#999999',
            description = 'Subject terminated prior to visit'
        ),
        list(
            status = 'Failed',
            order = 6,
            status_color = '#999999',
            description = 'Subject failed screening'
        )
    )

### Data manipulation
    visits <- sv %>%
        left_join(
            select(dm, USUBJID, SITE, SBJTSTAT, SAFFL),
            by = 'USUBJID'
        )  %>%
        left_join(
            select(scheduleOfEvents, VISIT, VISITOID),
            by = 'VISIT'
        ) %>%
        rename(
            subjectnameoridentifier = USUBJID,
            site_name = SITE,
            subject_status = SBJTSTAT,
            visit_name = VISIT,
            visit_abbreviation = VISITOID,
            visit_number = VISITNUM,
            visit_date = SVDT,
            visit_day = SVDY,
            visit_status = SVSTATUS
        )

    # Attach visit metadata as columns in data frame.
    for (i in 1:nrow(visits)) {
        visit_metadatum <- visit_metadata[
            which(sapply(visit_metadata, '[[', 1) == visits[i,'visit_status'])
        ][[1]]

        visits[i,'visit_status_order'] = visit_metadatum$order
        visits[i,'visit_status_color'] = visit_metadatum$status_color
        visits[i,'visit_status_description'] = visit_metadatum$description
    }

    # Derive additional variables.
    overdueVisits <- visits %>%
        filter(visit_status == 'Overdue') %>%
        group_by(subjectnameoridentifier) %>%
        mutate(
            nOverdue = n()
        ) %>%
        ungroup()
    overdue2 <- unique(pull(filter(overdueVisits, nOverdue > 1), subjectnameoridentifier))
    visits1 <- visits %>%
        mutate(
            visit_abbreviation = case_when(
                visit_abbreviation != '' ~ visit_abbreviation,
                grepl('^Unscheduled', visit_name) ~ paste0('UNS', word(visit_name, 2)),
                visit_name == 'Early Termination' ~ 'ET',
                TRUE ~ '???'
            ),
            visit_text = case_when(
                visit_status %in% c('Expected', 'Overdue') ~ visit_date,
                TRUE ~ visit_status
            ),
            subset1 = ifelse(subject_status == 'Ongoing', 'Active Participants', ''),
            subset2 = ifelse(grepl('^(Visit \\d)$', visit_name), 'On Treatment', ''),
            subset3 = ifelse(SAFFL == 'Y', 'Safety Population', ''),
            overdue2 = ifelse(subjectnameoridentifier %in% overdue2, 'Yes', ''),
            plot_exclude = ifelse(visit_status %in% c('Failed', 'Terminated'), 'Yes', '')
        ) %>%
        select(
            site_name,
            subjectnameoridentifier,
            subject_status,
            visit_name,
            visit_abbreviation,
            visit_number,
            visit_date,
            visit_day,
            visit_status,
            visit_status_order,
            visit_status_color,
            visit_status_description,
            visit_text,
            subset1,
            subset2,
            subset3,
            overdue2,
            plot_exclude
        )

### Output data
    visits1 %>%
        write.csv(
            '../visits.csv',
            na = '',
            row.names = FALSE
        )