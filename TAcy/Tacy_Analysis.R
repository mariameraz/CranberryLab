# Load libraries
library(tidyverse)

# Set working directoty
setwd('~/Documents/GitHub/CranberryLab/TAcy/')

# Read data 
data <- read.csv('tacy_data.csv', header = T)

metadata <- read.csv('Plant_Material.csv', header = T)
metadata$Sample_code <- paste(metadata$Row, metadata$Col, sep = '-')

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
conc_data <- tacy_conc(data)

dim(data)
