rm(list = ls())
library(tidyverse)
set.seed(2357)

#-------------------------------------------------------------------------------------------------#
# Input data
#-------------------------------------------------------------------------------------------------#

    forms <- read.csv('../../source/forms.csv', colClasses = 'character', check.names = FALSE)
    dm <- read.csv('../../sdtm/dm.csv', colClasses = 'character')
    sv <- read.csv('../../sdtm/sv.csv', colClasses = 'character')
    snapshotDate <- as.Date('2016-12-31')

### Output data
    #write.csv(
    #    forms1,
    #    '../forms.csv',
    #    row.names = FALSE
    #)