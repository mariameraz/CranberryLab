# Load libraries
library(tidyverse)

# Set working directory
setwd('~/Documents/GitHub/CranberryLab/Fungus_Biodiversity/')

# Load data
fungus_list <- read.csv('Fungus_list.csv',header = T) %>% select(-Details)

View(fungus_list)
abundance <- read.csv('allsample.all.reabundance.csv', header = T)

abundance$Species <- gsub('^.*_(.*)$', '\\1', abundance$Species)

fungus_list[(fungus_list$Genus %in% abundance$Genus),]

 
abundance[(abundance$Genus %in% fungus_list$Genus),] %>%
  select(Phylum, Class, Order, Family, Genus, Species)

write.csv(temp, 'Genus_present.csv', row.names = F, quote = F)
