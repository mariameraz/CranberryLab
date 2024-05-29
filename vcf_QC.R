library(vcfR)
library(tidyverse)

setwd('cran/VCFs/')
# LOADING SNPs DATA
vcf <- read.vcfR('filtered.vcf', convertNA = T)
## Meta lines: 73
## Header line: 74
## Variant count (SNPs): 280603
## Column count (samples): 479

# EXTRACT GENOTYPES
snps_num <- extract.gt(vcf, 
                       element = "GT",
                       IDtoRowNames  = F,
                       as.numeric = T,
                       convertNA = T,
                       return.alleles = F)
gt_info <- snps_num

# How many NAs are for each sample?
na_info <- colSums(is.na(gt_info)) 
summary(na_info)

# Remove samples with more than 25% NAs
# 25% threslhold: 
round(nrow(gt_info) * 0.25)

gt_info %>% str_subset(., '/') %>% table
