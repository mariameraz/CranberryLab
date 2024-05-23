library(vcfR)

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
