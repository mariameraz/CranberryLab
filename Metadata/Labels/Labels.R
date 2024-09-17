library(tidyverse)
metadata <- read.csv('Documents/CranLab/DiversityPanel_PopStruc/Metadata/DiversityPanel_tags.csv', 
                     fill = T,header = T)


metadata$Sample_name <- gsub("[^a-zA-Z0-9]", "",metadata$Sample_name)
nrow(metadata)
metadata <- metadata[-446,] 

metadata <- metadata %>% mutate(Sample_id = paste(Sample_name, paste(Row, Col, sep = ','), sep = '   '))

write_tsv(metadata, 'Documents/CranLab/DiversityPanel_PopStruc/Metadata/DiversityPanel_tags.tsv')
