### Examining stats in the VCF
# Tutorial: https://speciationgenomics.github.io/filtering_vcfs/

# Load libraries
library(tidyverse)
library(ggplot2)

# Set working directory 
setwd('~/Documents/DiversityPanel_PopStruc/Backcross/BP_VCF_stats/')

# QUALITY per site
#-------
# Load the quality info
var.qual <- read_delim('vcf_BC.lqual', delim = '\t')

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
var.depth <- read_delim('vcf_BC.ldepth.mean', delim = '\t')
head(var.depth)
summary(var.depth$MEAN_DEPTH)


ggplot(var.depth, aes(MEAN_DEPTH)) +
  geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3) +
  theme_classic()

var.depth <- na.omit(var.depth)
percentil_95 <- quantile(var.depth$MEAN_DEPTH, 0.98)
percentil_95

percentil_6 <- quantile(var.depth$MEAN_DEPTH, 0.1)
percentil_6

# Missing data 
#-------------------
var_miss <- read_delim("vcf_BC.lmiss", delim = "\t")
summary(var_miss)

a <- ggplot(var_miss, aes(F_MISS)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()


# MAF
#------------------
var_freq <- read_delim("vcf_BC.frq", delim = "\t",
                       col_names = c("chr", "pos", "nalleles", "nchr", "a1", "a2"), skip = 1)
head(var_freq)


# find minor allele frequency
var_freq$maf <- var_freq %>% select(a1, a2) %>% apply(1, function(z) min(z))

a <- ggplot(var_freq, aes(maf)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()
summary(var_freq)

# Stats per individuals
#----------------

metadata <- read.csv('../diversity.samples.txt', header = T) 

# Mean depth per individuals

ind_depth <- read_delim("vcf_BC.idepth", delim = "\t",
                        col_names = c("ind", "nsites", "depth"), skip = 1)

#ind_depth <- ind_depth %>%
#                left_join(metadata, by = c("ind" = "code"))

a <- ggplot(ind_depth, aes(depth)) +
  geom_density()
a + theme_light()

summary(ind_depth)

# NAs per ind 
#----------
ind_miss  <- read_delim("vcf_BC.imiss", delim = "\t",
                        col_names = c("ind", "ndata", "nfiltered", "nmiss", "fmiss"), skip = 1) 

a <- ggplot(ind_miss, aes(fmiss)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()
summary(ind_miss)
View(ind_miss)

# Heterozigocity and Breeding coefficient
#-----------
metadata <- read.csv('~/Documents/DiversityPanel_PopStruc/Metadata/metadata.csv', header = T)


ind_het <- read_delim("vcf_BC.het", delim = "\t",
                      col_names = c("Code","ho", "he", "nsites", "f"), skip = 1) 

ind_het <- left_join(ind_het, metadata, by = 'Code')


a <- ggplot(ind_het, aes(f)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()
summary(ind_het)
View(ind_het)
