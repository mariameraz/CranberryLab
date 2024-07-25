# Load libraries
library(vcfR)
library(vegan)
library(ggplot2)
library(ggpubr)
library(factoextra)
library(tidyverse)
library(ggrepel)
library(RColorBrewer)

# Set working directory
setwd('~/VACCap/')

# Load vcf file
vcf <- read.vcfR('filtered.vcf', convertNA = TRUE)

## EXTRACT GENOTYPES
# extract.gt isolates elements from the 'gt' portopn of the VCF data.
# NOTE: If the matrix is not numeric, the 'as.numeric' option will give you a numeric result which may not be interpretable.

gt.data <- extract.gt(vcf, 
                       element = "GT", # extract genotypes
                       IDtoRowNames  = F, # Do not use the ID column from the FIX region as rownames
                       as.numeric = F, # Should the matrix be converted to numeric? >>>> Be careful in this step, may be you should look at the no transformated data first. Find more info in vcfR documentation.
                       convertNA = T, # '.' are converted to 'NA'
                       return.alleles = F) # logical indicating whether to return genotypes (0/1) or alleles (A/T)


head(gt.data)

# Rename the colnames of our dataset
samples <- read.csv('samples.csv', header = T)

# Extracting new col names
new.colnames <- samples %>%
  filter(RAPiD.Genomics.Sample.Code %in% colnames(gt.data)) %>%
  pull(Unique.Client.Code)

# Create a new vector for the new names
rename.vector <- setNames(samples$Unique.Client.Code[samples$RAPiD.Genomics.Sample.Code %in% colnames(gt.data)],
                          samples$RAPiD.Genomics.Sample.Code[samples$RAPiD.Genomics.Sample.Code %in% colnames(gt.data)])

# Rename all the columns of the gt.data matrix 
gt.data.rename <- gt.data %>%
                    as.data.frame() %>% # Data needs to be converted first to df 
                    rename_with(~ rename.vector[.x], .cols = colnames(gt.data))

head(gt.data.rename)

# How many NAs are in each sample (column)?
na.data <- is.na(gt.data) %>%
  colSums() %>%
  as.data.frame() %>% 
  dplyr::rename(na_value = '.')
