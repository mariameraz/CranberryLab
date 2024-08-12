### Examining stats in the VCF

# Load libraries
library(tidyverse)
library(ggplot2)

# Set working directory 
setwd('~/Documents/CranLab/DiversityPanel_PopStruc/vcftools/')

## Plot the distribution of the variant quality

# Load the quality info
var.qual <- read_delim('vcf_subset.lqual', delim = '\t')

# Density plot
ggplot(var.qual, aes(QUAL)) +
  geom_density()

# Distribution of the phred values
summary(var.qual$QUAL)

table(var.qual$QUAL < 30)

# Check the probabilities
phred_scores <- var.qual$QUAL
probabilities <- 10^(-phred_scores / 10)
summary(probabilities)

# Variant mean depth
var.depth <- read_delim('vcf_subset.ldepth.mean', delim = '\t')
