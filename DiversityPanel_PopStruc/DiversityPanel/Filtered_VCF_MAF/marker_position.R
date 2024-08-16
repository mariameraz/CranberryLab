library(karyoploteR)
library(vcfR)
library(tidyverse)
library(rtracklayer)

setwd('~/Documents/CranLab/DiversityPanel_PopStruc/DiversityPanel/DP_VCF_stats/FILTERED_MAF/')

vcf <- read.vcfR('DP_filtered_biallelic.vcf.gz')

# Extract the info of the VCF
fix <- getFIX(vcf)
snp_pos <- fix %>% 
  as.data.frame %>% 
  select(CHROM, POS)

write.csv(snp_pos, 'snps_pos.csv', row.names = F)


gff <- import("V_macrocarpon_Stevens_v1-geneModels.gff3", format = "gff3")

# Filtrar por tipo de característica (por ejemplo, "region" para cromosomas)
chrom_regions <- gff[gff$type == "region", ]

# Crear un objeto GRanges
gr <- GRanges(seqnames = chrom_regions$seqnames,
              ranges = IRanges(start = chrom_regions$start, end = chrom_regions$end),
              strand = "*")
