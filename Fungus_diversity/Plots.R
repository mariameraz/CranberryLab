# Set working directory
setwd('/Users/alejandra/Documents/Becca/Work_2024/')

# Load libraries
library(tidyverse)
library(ggplot2) 
library(ggthemes) # ggplot theme used as template for plots
library(ggtext) # To use markdown in the plots
library(tidyr)
library(dplyr)
library(ggvenn)
library(UpSetR) 
library(VennDiagram)

# Loading the data
count.table <- read.csv('Counts for figure production-ErMFBiodiversity.csv')
dim(count.table)
count.table$Confirmed.species.ErMF..Putative.ErMF..Not.ErMF...C.P.N. %>% table()
# Create a new column with a unique ID for each OTU (row)
count.table$OTU <- paste('OTU',1:nrow(count.table), sep = '_')
# Saving a backup
count.table2 <- count.table

# Keeping mycorrhizal info
count.table<- 
  count.table %>% 
        rename(SpeciesStatus = Confirmed.species.ErMF..Putative.ErMF..Not.ErMF...C.P.N.) %>%
  filter(SpeciesStatus == 'P' | SpeciesStatus == 'C') %>%
  filter(!(Species == 'Meliniomyces_vraolstadiae'))

count.table$SpeciesStatus <- NULL

count.table$Genus %>% unique() %>% length() #208
count.table$Species %>% unique() %>% length() #251


count.table$Genus <- gsub('Scytalidium', 'Hyaloscypha', count.table$Genus)

# Convert the dataframe to long format
df_long <- tidyr::pivot_longer(count.table, 
                               cols = Bartling:WabasoLak, 
                               names_to = "Location", 
                               values_to = "Abundance")

# Change the names of the locations
# First we need to create a new data frame with the new labels for each location
metadata <- data.frame(Location = c("Bartling", 
                                    "BearLake",
                                    "Fabe.Pott",
                                    "FrogLake",
                                    "Gottschal",
                                    "GypsyLake",
                                    "Hansen",
                                    "Hayward",
                                    "Hydroponi",
                                    "Pippinger",
                                    "PowellMar",
                                    "ShelpLake",
                                    "WabasoLak"),
                       Type = c('Cultivated 1',
                                'Wild 7',
                                'Cultivated 2',
                                'Wild 5',
                                'Cultivated 3',
                                'Wild 4',
                                'Cultivated 4',
                                'Wild 2',
                                'Control',
                                'Cultivated 5',
                                'Wild 6',
                                'Wild 3',
                                'Wild 1'))

# ------------------------------------------------------------------------------

## Stacked bar plots

# Create a new column with the new label called Label
df_long <- df_long %>% 
  mutate(Label = ifelse(Location %in% metadata$Location, metadata$Type))
head(df_long)



df_long$Species <- gsub('Scytalidium_vaccinii', 'Hyaloscypha hepaticicola', df_long$Species)
df_long$Species <- gsub('Oidiodendron_citrinum', 'Oidiodendron maius var citrinum', df_long$Species)



# Summarize the abundance by Location and Genus
df_summary <- df_long %>%
  dplyr::group_by(Label, Genus) %>% # Change here the word Species to the level you prefer to get the summarize (Genus, Family, ...)
  dplyr::summarize(TotalAbundance = sum(Abundance), .groups = 'drop')

df_summary$Label <- factor(df_summary$Label, levels = c('Cultivated 1', 'Cultivated 2', 'Cultivated 3',
                                                        'Cultivated 4', 'Cultivated 5',
                                                        'Wild 1', 'Wild 2', 'Wild 3', 'Wild 4', 'Wild 5',
                                                        'Wild 6', 'Wild 7', 'Control'))
 

my_colors <- c('#65b413','#ea0f47', '#710461', '#bd6d9c', '#50b1b3', '#485195','#fdbf54')

# Definir etiquetas personalizadas para la leyenda con markdown
labels <- c('*Hyaloscypha*',
            '*Meliniomyces*',
            '*Oidiodendron*',
            '*Pezicula*',
            '*Pezoloma*',
            '*Rhizoscyphus*',
            '*Serendipita*')

# Create the stacked bar plot for species
ggplot(df_summary, aes(x = Label, y = TotalAbundance, fill = Genus)) +
  geom_bar(stat = "identity", position = 'stack') +
  labs(title = "Genus Diversity across Locations",
       x = "Location",
       y = "Total Abundance") +
  scale_x_discrete(expand = c(0, 0)) +  # Adjust the space of the x axis
  #scale_y_continuous(breaks = seq(0, 6500, by = 1000)) +
  scale_y_continuous(expand = c(0, 0)) +  # Adjust the space of the y axis
   scale_fill_manual(values = my_colors,
                     labels = labels) +
  theme_tufte() +
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



# Species level

# Summarize the abundance by Location and Genus
df_summary <- df_long %>%
  dplyr::group_by(Label, Species) %>% # Change here the word Species to the level you prefer to get the summarize (Genus, Family, ...)
  dplyr::summarize(TotalAbundance = sum(Abundance), .groups = 'drop')

df_summary$Label <- factor(df_summary$Label, levels = c('Cultivated 1', 'Cultivated 2', 'Cultivated 3',
                                                        'Cultivated 4', 'Cultivated 5',
                                                        'Wild 1', 'Wild 2', 'Wild 3', 'Wild 4', 'Wild 5',
                                                        'Wild 6', 'Wild 7', 'Control'))


my_colors <- c('#fdbf54','#ea0f47', '#710461', '#1a1334', '#f2999e','#8edb57',
               '#4e7bad', '#63463a', '#008592', '#086045', '#e47140','#ea297d')


# Definir etiquetas personalizadas para la leyenda con markdown
# New labels for each specie
labels <- c("*Hyaloscypha* finlandica",
            '*Meliniomyces* variabilis',
            '*Oidiodendron* maius var. citrinum',
            '*Pezicula* ericae',
            '*Pezoloma* ericae',
            '*Rhizoscyphus* monotropae',
            '*Scytalidium* vaccinii',
            '*Serendipita* sp',
            'Unclassified *Hyaloscypha*',
            'Unclassified *Pezicula*',
            'Unclassified *Serendipita*',
            'Unidentified')

# Create the stacked bar plot for species
ggplot(df_summary, aes(x = Label, y = TotalAbundance, fill = Species)) +
  geom_bar(stat = "identity", position = 'stack') +
  labs(title = "Species Diversity across Locations",
       x = "Location",
       y = "Total Abundance") +
  scale_x_discrete(expand = c(0, 0)) +  # Adjust the space of the x axis
  #scale_y_continuous(breaks = seq(0, 6500, by = 1000)) +
  scale_y_continuous(expand = c(0, 0)) +  # Adjust the space of the y axis
  scale_fill_manual(values = my_colors,
                    labels = labels) +
  theme_tufte() +
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


#-------------------------------------------------------------------------------

## Venn diiagram

# Create a new column for the status of the location (just wild, dom or control)
df_long$Status <- gsub('([a-z]) .*','\\1', df_long$Label)
colnames(df_long)


# Summarize the abundance by Location and SPECIES
df_summary <- df_long %>%
  dplyr::group_by(Label, Species) %>%
  dplyr::summarize(TotalAbundance = sum(Abundance), .groups = 'drop')

df_summary$Status <- gsub('([a-z]) .*','\\1', df_summary$Label)

# Summarize the presence of species by Status
df_summary <- df_long %>%
  filter(Abundance > 0) %>%
  group_by(Species, Status) %>%
  summarize(Presence = n(), .groups = 'drop')
df_summary

# Create sets for Venn Diagram
wild_species <- unique(df_summary %>% filter(Status == "Wild") %>% pull(Species))
cultivated_species <- unique(df_summary %>% filter(Status == "Cultivated") %>% pull(Species))
control_species <- unique(df_summary %>% filter(Status == "Control") %>% pull(Species))

# Create a list of species sets
species_sets <- list(
  Wild = wild_species,
  Cultivated = cultivated_species,
  Control = control_species
)

species_sets

ggvenn(species_sets, fill_color = c("#789eb7", "#eea938", "#76c170"),
       stroke_size = 0.5, set_name_size = 9, text_size = 8)

# Genus

# Summarize the presence of species by Status
df_summary <- df_long %>%
  filter(Abundance > 0) %>%
  group_by(Genus, Status) %>%
  summarize(Presence = n(), .groups = 'drop')


# Create sets for Venn Diagram
wild_species <- unique(df_summary %>% filter(Status == "Wild") %>% pull(Genus))
cultivated_species <- unique(df_summary %>% filter(Status == "Cultivated") %>% pull(Genus))
control_species <- unique(df_summary %>% filter(Status == "Control") %>% pull(Genus))

# Create a list of species sets
genus_sets <- list(
  Wild = wild_species,
  Cultivated = cultivated_species,
  Control = control_species
)



ggvenn(genus_sets, fill_color = c("#789eb7", "#eea938", "#76c170"),
       stroke_size = 0.5, set_name_size = 9, text_size = 8)


# OTUs

# Summarize the presence of species by Status
df_summary <- df_long %>%
  filter(Abundance > 0) %>%
  group_by(OTU, Status) %>%
  summarize(Presence = n(), .groups = 'drop')


# Create sets for Venn Diagram
wild_species <- unique(df_summary %>% filter(Status == "Wild") %>% pull(OTU))
cultivated_species <- unique(df_summary %>% filter(Status == "Cultivated") %>% pull(OTU))
control_species <- unique(df_summary %>% filter(Status == "Control") %>% pull(OTU))

# Create a list of species sets
otu_sets <- list(
  Wild = wild_species,
  Cultivated = cultivated_species,
  Control = control_species
)



ggvenn(otu_sets, fill_color = c("#789eb7", "#eea938", "#76c170"),
       stroke_size = 0.5, set_name_size = 9, text_size = 8)

#-------------------------------------------------------------------------------

## Upset plot

df <- data.frame(OTU = unique(df_long$OTU))
cult1 <- df_long %>% filter(Label == 'Cultivated 1')
cult2 <- df_long %>% filter(Label == 'Cultivated 2')
cult3 <- df_long %>% filter(Label == 'Cultivated 3')
cult4 <- df_long %>% filter(Label == 'Cultivated 4')
cult5 <- df_long %>% filter(Label == 'Cultivated 5')

wild1 <- df_long %>% filter(Label == 'Wild 1')
wild2 <- df_long %>% filter(Label == 'Wild 2')
wild3 <- df_long %>% filter(Label == 'Wild 3')
wild4 <- df_long %>% filter(Label == 'Wild 4')
wild5 <- df_long %>% filter(Label == 'Wild 5')
wild6 <- df_long %>% filter(Label == 'Wild 6')
wild7 <- df_long %>% filter(Label == 'Wild 7')

control <- df_long %>% filter(Label == 'Control')

df <-
df %>% mutate('Cultivated 1'=ifelse(OTU %in% cult1$OTU & cult1$Abundance > 0, 1,0),
              'Cultivated 2'=ifelse(OTU %in% cult2$OTU & cult2$Abundance > 0, 1,0),
              'Cultivated 3'=ifelse(OTU %in% cult3$OTU & cult3$Abundance > 0, 1,0),
              'Cultivated 4'=ifelse(OTU %in% cult4$OTU & cult4$Abundance > 0, 1,0),
              'Cultivated 5'=ifelse(OTU %in% cult5$OTU & cult5$Abundance > 0, 1,0),
              'Wild 1'=ifelse(OTU %in% wild1$OTU & wild1$Abundance > 0, 1,0),
              'Wild 2'=ifelse(OTU %in% wild2$OTU & wild2$Abundance > 0, 1,0),
              'Wild 3'=ifelse(OTU %in% wild3$OTU & wild3$Abundance > 0, 1,0),
              'Wild 4'=ifelse(OTU %in% wild4$OTU & wild4$Abundance > 0, 1,0),
              'Wild 5'=ifelse(OTU %in% wild5$OTU & wild5$Abundance > 0, 1,0),
              'Wild 6'=ifelse(OTU %in% wild6$OTU & wild6$Abundance > 0, 1,0),
              'Wild 7'=ifelse(OTU %in% wild7$OTU & wild7$Abundance > 0, 1,0),
              'Control'=ifelse(OTU %in% control$OTU & control$Abundance > 0, 1,0))


df$OTU <- NULL


# Define colors
slam_colours = c(  "#76c170", rep('#eea938', times = 7), rep("#789eb7", times = 5)) %>% ## slam colours (too cute, I know)
  rev()


# How to get specifics intersections
df[rowSums(df == 1) == 3, ]

df[df$`Cultivated 1`  == 1 &  df$`Cultivated 2` == 1, ]

View(df)
upset(df, nsets = 13, text.scale = 2.5, order.by = "freq", keep.order = T, sets.bar.color = slam_colours,
      mainbar.y.label = "Number of OTUs",
      sets.x.label = "Locations",
      query.legend = "none",
      queries = list(
        list(
          query = intersects,
          params = list('Control'),
          active = T,
          query.name = "Unique OTUs",
          color = "#76c170"),
        list(
          query = intersects,
          params = list('Wild 1'),
          active = TRUE,
          color = "#eea938"),
      list(
        query = intersects,
        params = list('Wild 2'),
        active = TRUE,
        color = "#eea938"),
      list(
        query = intersects,
        params = list('Wild 3'),
        active = TRUE,
        color = "#eea938"),
      list(
        query = intersects,
        params = list('Wild 4'),
        active = TRUE,
        color = "#eea938"),
      list(
        query = intersects,
        params = list('Wild 5'),
        active = TRUE,
        color = "#eea938"),
      list(
        query = intersects,
        params = list('Wild 6'),
        active = TRUE,
        color = "#eea938"),
      list(
        query = intersects,
        params = list('Wild 7'),
        active = TRUE,
        color = "#eea938"),
      list(
        query = intersects,
        params = list('Cultivated 1'),
        active = TRUE,
        color = "#789eb7"),
      list(
        query = intersects,
        params = list('Cultivated 2'),
        active = TRUE,
        color = "#789eb7"),
      list(
        query = intersects,
        params = list('Cultivated 3'),
        active = TRUE,
        color = "#789eb7"),
      list(
        query = intersects,
        params = list('Cultivated 4'),
        active = TRUE,
        color = "#789eb7"),
      list(
        query = intersects,
        params = list('Cultivated 5'),
        active = TRUE,
        color = "#789eb7")
      
      
))




