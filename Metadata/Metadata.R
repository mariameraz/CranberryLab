setwd('~/Documents/Harvest_2023/Diversity_Panel_H2023/DP_H2/')

setwd('/home/zalapa/Downloads/')

data <- read.csv('VAC_155005_Normal_Plate_Layout_02-08-2023_14-44-04.csv', header = T)
colnames(data) <- data[1,]
data <- data[-1,]

library(tidyverse)
data <- data[!(data$`Unique Client Code` == 'N/A'),]

data <- data[grep('P00[1-5]', data$`RAPiD Genomics Sample Code`),]

data <- data[c(3,4)]
write.csv(data, 'samples.csv')

## Filter samples by population

library(tidyverse)

setwd('~/Documents/CranLab/DiversityPanel_PopStruc/')

samples <- read_delim('Metadata/samples.csv', delim = ',', col_names = c('X', 'Code', 'ID'), skip = 1) %>% 
  select(-X) 
exp <- read_tsv('Metadata/lab_snps_data.tsv', col_names = T) %>% 
  filter(Genotyped == 'Yes')

plant_info <- read.csv('Metadata/DiversityPanel-PlantInfo.csv', header = T, fill = T) %>% 
  select(Plot.Name, Type) %>% rename(ID = Plot.Name)

head(plant_info)

exp$Experiment %>% table()

samples <- left_join(samples, exp, by = 'ID')
samples <- left_join(samples, plant_info, by = 'ID')

samples$Genotyped %>% table(exclude = T)

write.csv(samples, 'Metadata/metadata.csv', quote = F,row.names = F, col.names = T)


dp_cb_samples <- samples %>% filter(Experiment == 'Diversity panel' | 
                                   Experiment == 'Color panel') %>% 
  filter(!(Code == 'VAC_155005_P001_WA11')) %>%
  select(Code)

dp_samples <- samples %>% filter(Experiment == 'Diversity panel') %>% 
  filter(!(Code == 'VAC_155005_P001_WA11')) %>%
  select(Code) 

cb_samples <- samples %>% filter(Experiment == 'Color panel') %>% 
  select(Code)

write.table(dp_samples, 'diversity.samples.txt', quote = F, col.names = F, row.names = F)
write.table(cb_samples, 'color.samples.txt', quote = F, col.names = F, row.names = F)
write.table(dp_cb_samples, 'samples.txt', quote = F, col.names = F, row.names = F)



