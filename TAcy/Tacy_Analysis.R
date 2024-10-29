# Load libraries:
library(tidyverse)

# Set working directory:
setwd('~/Documents/CranLab/TAcy/')

# Load data:
data <- read.csv('extracted_data.csv', header = T,fill = T)
data <- na.omit(data)
data <- data %>% filter(Person != 'Ree', Harvest == 1)

# Load tacy_conc function to calculate the concentration of anthocyanins
source('tacy_conc.R')
tacy_conc(data = data) %>% View()
