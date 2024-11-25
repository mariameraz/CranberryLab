# Load libraries
library(tidyverse)

# Set working directory
path <- '~/Documents/CranLab/H1-2023-CP/First harvest Sep-13-2023/'

files <- list.files(path, pattern = '.jpg')
new <- gsub('\\.jpg', '', files) # Detele .jpg end 
new <- gsub('[-()#_\' ]', '', new) # Delete special characters
new <- tolower(new) # Lower characters 

new <- gsub('(stevens)([1-9]$)', '\\10\\2', new)
new

# Load new IDs
samples <- read.csv('~/Documents/GitHub/CranberryLab/Metadata/Plant_Material.csv',
                    header = T) %>% mutate(Sample_name = tolower(Sample_name))



all(new %in% samples$Sample_name)

## Change for the code
color_panel <- samples %>% filter(Population == 'ColorPanel')
names <- data.frame(Sample_name = new)
names <- names %>% left_join(color_panel, by = 'Sample_name', ) %>% 
  filter(Sample_name %in% samples$Sample_name) %>% 
  arrange(match(Sample_name, new)) %>% pull(Sample_code)

# Define new names and its path

old_names <- paste(path, files, sep = '')
new_names <- paste(path, paste(names, 'jpg', sep = '.'), sep = '')

# Rename the files
file.rename(old_names, new_names)








