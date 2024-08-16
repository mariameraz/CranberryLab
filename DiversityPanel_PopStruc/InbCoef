library(adegenet)
library(vcfR)

# Set working directory 
setwd('~/Documents/CranLab/DiversityPanel_PopStruc/DiversityPanel/DP_VCF_stats/FILTERED_MAF/')

vcf <- read.vcfR("DP_filtered_V2.vcf.gz")
genind <- vcfR2genind(vcf)
inbreeding_coeff <- inbreeding(genind)
