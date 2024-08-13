### Examining stats in the VCF
# Tutorial: https://speciationgenomics.github.io/filtering_vcfs/

# Load libraries
library(tidyverse)
library(ggplot2)

# Set working directory 
setwd('~/Documents/DiversityPanel_PopStruc/vcftools_stats/')

# QUALITY per site
#-------
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


# DEPTH per site
#---------------------
# Variant mean depth
var.depth <- read_delim('vcf_subset.ldepth.mean', delim = '\t')
head(var.depth)
summary(var.depth$MEAN_DEPTH)


ggplot(var.depth, aes(MEAN_DEPTH)) +
  geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3) +
  theme_classic()

percentil_95 <- quantile(var.depth$MEAN_DEPTH, 0.98)
percentil_95

percentil_6 <- quantile(var.depth$MEAN_DEPTH, 0.06)
percentil_6

# Missing data 
#-------------------
var_miss <- read_delim("vcf_subset.lmiss", delim = "\t")
summary(var_miss)

a <- ggplot(var_miss, aes(F_MISS)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()
summary(var_miss)

# MAF
#------------------
var_freq <- read_delim("vcf_subset.frq", delim = "\t",
                       col_names = c("chr", "pos", "nalleles", "nchr", "a1", "a2"), skip = 1)
head(var_freq)
summary(var_freq)

# find minor allele frequency
var_freq$maf <- var_freq %>% select(a1, a2) %>% apply(1, function(z) min(z))

a <- ggplot(var_freq, aes(maf)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()

# Stats per individuals
#----------------

metadata <- read.csv('samples.csv', header = T) %>% 
  select(-X) %>% 
  rename(sample = Unique.Client.Code, code = RAPiD.Genomics.Sample.Code) 

# Mean depth per individuals

ind_depth <- read_delim("vcf_subset.idepth", delim = "\t",
                        col_names = c("ind", "nsites", "depth"), skip = 1)

ind_depth <- ind_depth %>%
                left_join(metadata, by = c("ind" = "code"))

a <- ggplot(ind_depth, aes(depth)) +
  geom_density()

a + theme_light()

summary(ind_depth)

# NAs per ind 
#----------
ind_miss  <- read_delim("vcf_subset.imiss", delim = "\t",
                        col_names = c("ind", "ndata", "nfiltered", "nmiss", "fmiss"), skip = 1) %>%
                        left_join(metadata, by = c("ind" = "code"))
a <- ggplot(ind_miss, aes(fmiss)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()
summary(ind_miss)
View(ind_miss)

# Heterozigocity and Breeding coefficient
#-----------
ind_het <- read_delim("vcf_subset.het", delim = "\t",
                      col_names = c("ind","ho", "he", "nsites", "f"), skip = 1) %>%
  left_join(metadata, by = c("ind" = "code"))

a <- ggplot(ind_het, aes(f)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()
summary(ind_het)
