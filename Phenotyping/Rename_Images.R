# Rename files

# Set working directory
directory <- '~/Documents/CranLab/DiversityPanel/Phenotyping/Harvest1_2023/Images/'

files <- list.files(directory)
new <- gsub(' ', '-', files) 
new <- gsub('#','',new)
new <- gsub('\'','',new)

# Define new names and its path
old_names <- file.path(directory, files)
new_names <- file.path(directory, new)

# Rename the files
file.rename(old_names, new_names)
