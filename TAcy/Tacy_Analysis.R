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

# Get the mean concentration value







weight_data <- read.csv('Weight_H1_2023.csv', header = TRUE)
weight_data$Sample_name <- toupper(weight_data$Sample_name)
weight_data$Sample_name <- gsub('[\\. ()]', '', weight_data$Sample_name)
weight_data$Sample_name <- gsub('(STEVENS)([1-9]$)', '\\10\\2', weight_data$Sample_name)


h1_2023 <- weight_data[(weight_data$Sample_name %in% metadata$Sample_name),] %>% 
  dplyr::select(Sample_name, Fruit_n, Total_weight, Avg_weight)

tacy_2023 <- conc_data %>% filter(Harvest == 1 )

tacy <- left_join(tacy_2023, 
          h1_2023, by = 'Sample_name', 
          relationship = 'many-to-many') %>% 
  mutate(Sample_Rep = paste(Sample_name, Rep, sep = '_')) %>% 
  filter(Population == 'DiversityPanel') %>% View


# write.csv(weight_data, 'Weight_H1_2023.csv', quote = F, row.names = F)
# 
# 
# left_join(weight_data, 
#           metadata %>% select(Sample_name, Sample_code), by = 'Sample_name')
