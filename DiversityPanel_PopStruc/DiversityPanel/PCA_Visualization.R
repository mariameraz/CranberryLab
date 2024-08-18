library(tidyverse)
setwd('~/Documents/CranLab/DiversityPanel_PopStruc/DiversityPanel/DP_VCF_stats/FILTERED_MAF/')

metadata <- read.csv('../../../Metadata/metadata.csv', header = T)
pca <- read_table2('dp.eigenvec', col_names = T)
eigenval <- scan('dp.eigenval')


# sort out the pca data
# remove nuisance column
pca <- pca[,-1]
# set names
names(pca)[1] <- "Code"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))

head(pca)
pca <- left_join(pca, metadata, by = 'Code')
colnames(pca)

# first convert to percentage variance explained
pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)

ggplot(pve, aes(PC, pve)) + 
  geom_bar(stat = "identity") + 
  ylab("Percentage variance explained") + theme_light()

# calculate the cumulative sum of the percentage variance explained
cumsum(pve$pve)

# plot pca
ggplot(pca, aes(PC1, PC2, col = Type)) + 
  geom_point(size = 3) + 
  scale_colour_manual(values = c("red", "blue", 'green','yellow','purple','pink')) + coord_equal() +
  theme_light() + xlab(paste0("PC1 (", signif(pve$pve[1], 3), "%)")) +
  ylab(paste0("PC2 (", signif(pve$pve[2], 3), "%)"))
