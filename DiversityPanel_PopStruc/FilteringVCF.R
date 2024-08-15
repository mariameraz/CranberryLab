# Load libraries
library(vcfR)
library(ggplot2)
library(tidyverse)


# Set working directory
setwd('~/VACCap/')

# Load vcf file
vcf <- read.vcfR('filtered.vcf', convertNA = TRUE)

## GET FIXED DATA
fix.data <- getFIX(vcf)
head(fix.data)

fix.data[,'ID'] %>% table(exclude = T)
## EXTRACT GENOTYPES
# extract.gt isolates elements from the 'gt' portopn of the VCF data.
# NOTE: If the matrix is not numeric, the 'as.numeric' option will give you a numeric result which may not be interpretable.

gt.data <- extract.gt(vcf, 
                       element = "GT", # extract genotypes
                       IDtoRowNames  = F, # Do not use the ID column from the FIX region as rownames
                       as.numeric = F, # Should the matrix be converted to numeric?
                       #convertNA = T, # '.' are converted to 'NA'
                       return.alleles = F) # logical indicating whether to return genotypes (0/1) or alleles (A/T)


gt.data[,1]

# Create a backup, just in case..
gt.data.backup <- gt.data

# Rename the colnames of our dataset
samples <- read.csv('samples.csv', header = T)
samples[duplicated(samples$Unique.Client.Code),]

# Delete duplicated sample (!!! before to do this, I double checked that it was trully the same sample)
gt.data <- gt.data %>%
                as.data.frame() %>%
                select(-VAC_155005_P004_WB09)

samples <- samples[-303,]

# Extracting new col names
new.colnames <- samples %>%
  filter(RAPiD.Genomics.Sample.Code %in% colnames(gt.data)) %>%
  pull(Unique.Client.Code)

rename.vector <- setNames(samples$Unique.Client.Code[samples$RAPiD.Genomics.Sample.Code %in% colnames(gt.data)],
                          samples$RAPiD.Genomics.Sample.Code[samples$RAPiD.Genomics.Sample.Code %in% colnames(gt.data)])

gt.data <- gt.data %>%
                    as.data.frame() %>%
                    rename_with(~ rename.vector[.x], .cols = colnames(gt.data))

head(gt.data)

# How many NAs are in each sample (column)?
na.data <- is.na(gt.data) %>%
  colSums() %>%
  as.data.frame() %>% 
  dplyr::rename(na_value = '.')

summary(na.data)
# Create a new column with the % of NAs to facilitate the visualization
na.data <- na.data %>% mutate(perc_na = round((na_value/nrow(gt.data)*100, digits = 1))

# Create a boxplot to observe the distribution of the NA data
ggplot(na.data, aes(x = na_value)) +
  geom_boxplot() + 
  theme_classic()

na.data %>% summary()

thres25 <- na.data %>% arrange(desc(na_value)) %>% filter(perc_na < 25)
thres10 <- na.data %>% arrange(desc(na_value)) %>% filter(perc_na < 10)
nrow(thres25)

# Deleting samples with more than 25% of NAs
gt.data <- gt.data[,colnames(gt.data) %in% rownames(thres25)] 


## CONVERT GENOTYPIC DATA (gt IN VCF) TO ALLELE DOSAGE 
table(gt.data[,1])
dim(gt.data)

ds.data <- GT2DS(gt.data,n.core=2)


# Remove invariable SNPs
# Calculate the SD for each marker across all the samples
nrow(gt.data)

ds_snps <- apply(snps_num_df, 1, sd, na.rm = T)
table(ds_snps == 0)

# Save genetic data
#write.table(gt.data, 'gt.data.txt', quote = F,col.names = T)


