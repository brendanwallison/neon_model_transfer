# Code written by Ebenezer Fatunsin
# Data clean up
# read in the tree data 

library(readr)
alltree_TP <- read_csv("C:/Users/ebenf/OneDrive - The University of Alabama/Structural diversity/alltree_TP.csv")
View(alltree_TP)

#filter the datato include only data between 2015 - 2019 (5-year) inventory cycle
alltree_TP <- alltree_TP %>% filter(between(INVYR, 2015, 2019))
View(alltree_TP)

# keep only wanted columns for the analysis
# we need only trees, biomass and other covariates
# the code below shows the columns we are keeping
alltree_TP1 <- alltree_new[c(2:8,12:14,25,35,40,41,43,44:46)]

# check the range of the inventory year to be sure it is between 2015-2019
range(alltree_TP1$INVYR)

