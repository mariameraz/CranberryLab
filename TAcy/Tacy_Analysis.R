# Load libraries
library(tidyverse)

# Set working directoty
setwd('~/Documents/GitHub/CranberryLab/TAcy/')

# Read data 
data <- read.csv('tacy_data.csv', header = T)
metadata <- read.csv('Plant_Material.csv', header = T)
metadata$Sample_name <- toupper(metadata$Sample_name)

# Filtering data
data <-  data %>% 
  dplyr::filter( !(Person == 'Ree') & # 
                   nm_520 > 0 & 
                   nm_700 > 0)

# Do we have duplicated data?
duplicated_samples <- data %>% 
  summarise(n = n(), .by = c(pH, Rep, Sample_code, Harvest)) %>% 
  filter(n > 1)
unique(duplicated_samples$Sample_code) # 12 duplicated samples (24 samples mislabeled)

# Remove duplicated samples
data <- data[!(data$Sample_code %in% duplicated_samples$Sample_code),]

# Load Tacy concentration function
source('tacy_conc.R')

# Calculate tacy concentration
conc_data <- tacy_conc(data) %>% 
  left_join( metadata, by = 'Sample_code') 



weight_data <- read.csv('Weight_H1_2023.csv', header = TRUE)
weight_data$Sample_name <- toupper(weight_data$Sample_name)
weight_data$Sample_name <- gsub('[\\. ()]', '', weight_data$Sample_name)
weight_data$Sample_name <- gsub('(STEVENS)([1-9]$)', '\\10\\2', weight_data$Sample_name)

# write.csv(weight_data, 'Weight_H1_2023.csv', quote = F, row.names = F)
# 
# 
# weight_data[!(weight_data$Sample_name %in% metadata$Sample_name),]
# 
# left_join(weight_data, 
#           metadata %>% select(Sample_name, Sample_code), by = 'Sample_name')
