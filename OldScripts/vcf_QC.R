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
# 25% threshold: 
thres <- round(nrow(gt_info) * 0.25)

# Calculate number of NAs in each col

na_counts <- na_info %>% as.data.frame() %>% `colnames<-`('perc')
# Filter samples with high % (>75) of NAs
snps_num_df <- snps_num[na_counts$perc <= thres,]

dim(snps_num) - dim(snps_num_df)
head(snps_num_df)

# Remove invariable SNPs
# Calculate the SD for each marker across all the samples
nrow(snps_num_df)

ds_snps <- apply(snps_num_df, 1, sd, na.rm = T)
table(ds_snps == 0)
