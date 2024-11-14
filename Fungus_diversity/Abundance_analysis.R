# Load libraries
library(tidyverse)

# Set working directory
setwd('~/Documents/CranLab/Fungus_Biodiversity/')

# Load the list of organisms you are looking for
fungus_list <- read.csv('Fungus_list.csv',header = T) %>% select(-Details)

# Load the abundance table
abundance <- read.csv('allsample.all.reabundance.csv', header = T)
abundance$Species <- gsub('^.*_(.*)$', '\\1', abundance$Species)

# How many genus in 
fungus_list[(fungus_list$Genus %in% abundance$Genus),]

temp <- abundance[(abundance$Genus %in% fungus_list$Genus),] %>%
  select(Phylum, Class, Order, Family, Genus, Species)

write.csv(temp, 'Genus_present.csv', row.names = F, quote = F)
