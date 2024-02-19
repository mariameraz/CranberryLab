setwd('~/Documents/Harvest_2023/Diversity_Panel_H2023/DP_H2/')

files <- list.files(pattern = '.jpg')
file.rename(files, gsub('\\(|\\)|\\_|\\-','',files))

setwd('/home/zalapa/Downloads/')

data <- read.csv('VAC_155005_Normal_Plate_Layout_02-08-2023_14-44-04.csv', header = T)
colnames(data) <- data[1,]
data <- data[-1,]

library(tidyverse)
data <- data[!(data$`Unique Client Code` == 'N/A'),]

data <- data[grep('P00[1-5]', data$`RAPiD Genomics Sample Code`),]

data <- data[c(3,4)]
write.csv(data, 'samples.csv')
