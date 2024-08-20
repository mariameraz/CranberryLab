# Rename files

# Set working directory
directory <- '~/Documents/CranLab/DiversityPanel/Phenotyping/Harvest1_2023/Images/'

files <- list.files(directory)
temp <- gsub(' ', '-', files) 
temp <- gsub('#','',temp)
temp <- gsub('\'','',temp)
# Define new names
old_names <- file.path(directory, files)
new_names <- file.path(directory, temp)

# Rename the files
file.rename(old_names, new_names)
