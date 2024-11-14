# Load libraries
library(tidyverse)

# Set working directory
setwd('~/Documents/GitHub/CranberryLab/Fungus_Biodiversity/')

# Load data
fungus_list <- read.csv('Fungus_list.csv',header = T) %>% select(-Details)
abundance <- read.csv('allsample.all.reabundance.csv', header = T)

abundance$Species <- gsub('^.*_(.*)$', '\\1', abundance$Species)

# Which species in the fungus list are present in the abundance table?
fungus_list[(fungus_list$Species %in% abundance$Species),]

# Which species in the abundance table are also present in the fungus list? 
temp <- abundance[(abundance$Genus %in% fungus_list$Genus),] %>%
  select(Phylum, Class, Order, Family, Genus, Species)

# Save abundance filtered data
write.csv(temp, 'Genus_present.csv', row.names = F, quote = F)
