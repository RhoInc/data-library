rm(list = ls())
library(tidyverse)
set.seed(2357)
nQueries <- 5000

#-------------------------------------------------------------------------------------------------#
# Input data
#-------------------------------------------------------------------------------------------------#

    sites <- 1:5
    visits <- read.csv('../../data-dictionaries/schedule-of-events.csv', colClasses = 'character', check.names = FALSE)
    forms <- read.csv('../../data-dictionaries/forms.csv', colClasses = 'character', check.names = FALSE)
    fields <- read.csv('../../data-dictionaries/fields.csv', colClasses = 'character', check.names = FALSE)
    statuses <- c('Closed', 'Cancelled') # Open and Answered defined by query answered/resolved dates or lack thereof
    statusProbs <- c(.75, .25)
    markingGroups <- c('Site from System', 'Site from DM', 'Site from CRA')
    markingGroupProbs <- c(.7, .2, .1)
    snapshotDate <- as.Date('2016-12-31')
    queryDates <- seq(as.Date('2015-01-01'), snapshotDate, 1)
    responses <- runif(nQueries)
    resolvers <- runif(nQueries)

#-------------------------------------------------------------------------------------------------#
# Sample fields
#-------------------------------------------------------------------------------------------------#

    queries <- data.frame(
            sitename = rep('', nQueries),
            subjectnameoridentifier  = rep('', nQueries),
            folderoid = rep('', nQueries),
            formoid = rep('', nQueries),
            fieldname = rep('', nQueries),
            markinggroup = rep('', nQueries),
            queryopendate = rep(Sys.Date(), nQueries),
            queryresponsedate = rep(Sys.Date(), nQueries),
            queryresolveddate = rep(Sys.Date(), nQueries),
            querystatus = rep('', nQueries),
            odays = rep(0, nQueries),
            queryrecency = rep(0, nQueries), # also derived in renderer
            qdays = rep(0, nQueries),
            queryage = rep('', nQueries), # also derived in renderer
        stringsAsFactors = FALSE,
        check.names = FALSE
    )

    for (i in 1:nQueries) {
        query <- fields[sample(nrow(fields), 1),] # no need for select() with -Field because data no longer contains a field var for explaining field
        queries[i,'sitename'] <- paste(
            'Site',
            formatC(sample(sites, 1), width = 2, format = 'd', flag = '0')
        )
        queries[i,'subjectnameoridentifier'] <- paste(
            strsplit(queries[i,'sitename'], ' ')[[1]][[2]],
            formatC(sample(1:25, 1), width = 3, format = 'd', flag = '0'),
            sep = '-'
        )
        visit <- visits[
            ifelse(
                query[1,1] %in% c('SCRN', 'DM'),
                1,
                sample(nrow(visits), 1)
            ),
        ]
        queries[i,'folderoid'] <- visit$VISITOID
        queries[i,'folderinstancename'] <- visit$VISIT
        queries[i,'formoid'] <- query[1,1]
        queries[i,'fieldname'] <- query[1,2]
        queries[i,'markinggroup'] <- sample(markingGroups, 1, prob = markingGroupProbs)
        queries[i,'queryopendate'] <- sample(queryDates, 1)
        queries[i,'queryresponsedate'] <- sample(seq(queries[i,'queryopendate'], snapshotDate, 1), 1) # sample a date between query open date and the snapshot date
        if (responses[i] < .75) {
            queries[i,'queryresponsedate'] <- NA # simulate queries that never received a response
            queries[i,'queryresolveddate'] <- sample(seq(queries[i,'queryopendate'], snapshotDate, 1), 1) # sample a date between query open date and the snapshot date
        } else
            queries[i,'queryresolveddate'] <- sample(seq(queries[i,'queryresponsedate'], snapshotDate, 1), 1) # sample a date between query response date and the snapshot date
        if (resolvers[i] < .25)
            queries[i,'queryresolveddate'] <- NA # simulate queries that were never resolved
        queries[i,'querystatus'] <- case_when(
            is.na(queries[i,'queryresponsedate']) & is.na(queries[i,'queryresolveddate']) ~ 'Open',
            !is.na(queries[i,'queryresponsedate']) & is.na(queries[i,'queryresolveddate']) ~ 'Answered',
            TRUE ~ sample(statuses, 1, prob = statusProbs)
        )
        queries[i,'odays'] <- as.numeric(snapshotDate - queries[i,'queryopendate'])
        queries[i,'queryrecency'] <- case_when(
            queries[i,'odays'] <= 7 ~ '7 days',
            queries[i,'odays'] <= 14 ~ '14 days',
            queries[i,'odays'] <= 30 ~ '30 days',
            TRUE ~ ''
        )
        queries[i,'qdays'] <- case_when(
            queries[i,'querystatus'] == 'Answered' ~ as.numeric(queries[i,'queryresponsedate'] - queries[i,'queryopendate']),
            queries[i,'querystatus'] %in% c('Closed', 'Cancelled') ~ as.numeric(queries[i,'queryresolveddate'] - queries[i,'queryopendate']),
            TRUE ~ queries[i,'odays']
        )
        queries[i,'queryage'] <- case_when(
            queries[i,'querystatus'] %in% c('Answered', 'Closed', 'Cancelled') ~ queries[i,'querystatus'],
            queries[i,'qdays'] <=  14 ~ '0-2 weeks',
            queries[i,'qdays'] <=  28 ~ '2-4 weeks',
            queries[i,'qdays'] <=  56 ~ '4-8 weeks',
            queries[i,'qdays'] <= 112 ~ '8-16 weeks',
            TRUE ~ '>16 weeks'
        )
    }

    print(table(queries$querystatus))
    print(table(queries$queryrecency))
    print(table(queries$queryage))

    queries1 <- queries %>%
        left_join(forms) %>%
        left_join(fields) %>%
        mutate(
            queryopenby = markinggroup,
            querytext = 'query text',
            queryresponsetext = ifelse(!is.na(queryresponsedate), 'query response text', '')
        ) %>%
        select(
            sitename, subjectnameoridentifier, folderoid, folderinstancename, formoid, ecrfpagename, fieldname, fieldlabel, markinggroup, queryopenby, querytext, queryresponsetext, querystatus, queryopendate, queryresponsedate, queryresolveddate, odays, qdays
        )

### Output data
    write.csv(
        queries1,
        '../queries.csv',
        row.names = FALSE
    )
