# Load libraries
library(tidyverse)

# Set working directory
setwd('~/Documents/GitHub/CranberryLab/Fungus_diversity/')

# Load data
fungus_list <- read.csv('Fungus_list.csv',header = T) %>% select(-Details)
abundance <- read.csv('allsample.all.reabundance.csv', header = T)

abundance$Species <- gsub('^.*_(.*)$', '\\1', abundance$Species)

# Which species in the fungus list are present in the abundance table?
fungus_list[(fungus_list$Genus %in% abundance$Genus),]
fungus_list[(fungus_list$Species %in% abundance$Species),]

abundance_table <- abundance[abundance$Genus %in% fungus_list$Genus, ] 
write.csv(abundance_table, 'abundance_filtered.csv', quote = F, row.names = F)

# # Which species in the abundance table are also present in the fungus list? 
# temp <- abundance[(abundance$Genus %in% fungus_list$Genus),] %>%
#   select(Phylum, Class, Order, Family, Genus, Species)
# 
# # Save abundance filtered data
# write.csv(temp, 'Genus_present.csv', row.names = F, quote = F)

abundance_filt <- abundance %>% 
  filter(Genus %in% fungus_filt$Genus & Species %in% fungus_filt$Species)
colnames(abundance_filt)
# Convert the dataframe to long format
df_long <- tidyr::pivot_longer(abundance_filt, 
                               cols = B8.A:Control, 
                               names_to = "Location", 
                               values_to = "Abundance")
df_summary <- df_long %>%
  dplyr::group_by(Location, Genus, Species) %>% # Change here the word Species to the level you prefer to get the summarize (Genus, Family, ...)
  dplyr::summarize(TotalAbundance = sum(Abundance), .groups = 'drop')

my_colors <- c('#65b413','#ea0f47', '#710461', '#bd6d9c', '#50b1b3', '#485195','#fdbf54')

# Create the stacked bar plot for species
ggplot(df_summary, aes(x = Location, y = TotalAbundance, fill = Genus)) +
  geom_bar(stat = "identity", position = 'stack') +
  labs(title = "Genus Diversity across Locations",
       x = "Location",
       y = "Total Abundance") +
  scale_x_discrete(expand = c(0, 0)) +  # Adjust the space of the x axis
  #scale_y_continuous(breaks = seq(0, 6500, by = 1000)) +
  scale_y_continuous(expand = c(0, 0)) +  # Adjust the space of the y axis
  scale_fill_manual(values = my_colors) +
  theme(axis.line.x = element_line(size = 0.3, colour = 'black'),
        axis.line.y = element_line(size = 0.3, colour = 'black'),
        axis.text = element_text(size = 14),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        axis.title = element_text(size = 18),
        axis.title.y = element_text(margin = margin(r = 20)),
        axis.title.x = element_text(margin = margin(t = 20)),
        plot.title = element_text(size = 25, margin = margin(b = 40)),
        legend.title = element_text(size = 18, margin = margin(b = 10)),
        legend.text = element_markdown(size = 14))


# Calcular los porcentajes
df_summary <- df_summary %>%
  group_by(Location) %>%
  mutate(Percentage = TotalAbundance / sum(TotalAbundance) * 100)

# Crear el gráfico de barras apiladas en porcentaje
ggplot(df_summary, aes(x = Location, y = Percentage, fill = Genus)) +
  geom_bar(stat = "identity", position = 'stack') +
  labs(title = "Genus Diversity across Locations (%)",
       x = "Location",
       y = "Percentage") +
  scale_x_discrete(expand = c(0, 0)) +  # Ajustar el espacio del eje x
  scale_y_continuous(expand = c(0, 0), labels = scales::percent_format(scale = 1)) +  # Mostrar porcentajes en el eje y
  scale_fill_manual(values = my_colors) +
  theme(axis.line.x = element_line(size = 0.3, colour = 'black'),
        axis.line.y = element_line(size = 0.3, colour = 'black'),
        axis.text = element_text(size = 14),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        axis.title = element_text(size = 18),
        axis.title.y = element_text(margin = margin(r = 20)),
        axis.title.x = element_text(margin = margin(t = 20)),
        plot.title = element_text(size = 25, margin = margin(b = 40)),
        legend.title = element_text(size = 18, margin = margin(b = 10)),
        legend.text = element_markdown(size = 14))

