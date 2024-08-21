# Load libraries
library(ggplot2)
library(tidyverse)
library(reshape2)
library(pheatmap)
library(colorspace)
library(viridis)
# Load data
data <- read.csv('~/Documents/CranLab/Phenotyping/DPH1_2023/DPH1_2023.csv', header = T)

data$color_L_median <- (data$color_L_median*100)/255
summary(data$color_L_median)

head(data)

# Normalizar los valores de color RGB
data$color_R_normalized <- data$color_R_median / 255
data$color_G_normalized <- data$color_G_median / 255
data$color_B_normalized <- data$color_B_median / 255


# Crear el gráfico de puntos
ggplot(data, aes(x = color_R_normalized, 
                     y = color_G_normalized, 
                     color = rgb(color_R_normalized, color_G_normalized, color_B_normalized))) +
  geom_point(size = 3) +
  scale_color_identity() +
  theme_minimal() +
  labs(title = "Colores Predominantemente Rojos",
       x = "R Normalizado",
       y = "G Normalizado")

# Supongamos que tus datos están en un data frame llamado `data`
# Asegúrate de que tienes columnas 'color_R_median' y 'color_L_median'

# Crear el gráfico de puntos
ggplot(data, aes(x = color_R_median, y = color_L_median)) +
  geom_point(size = 3, aes(color = rgb(color_R_median / 255, 0, 0))) +  # Color rojo basado en R
  scale_color_identity() +
  theme_minimal() +
  labs(title = "Relación entre R (RGB) y L (CIELAB)",
       x = "R (RGB)",
       y = "L (CIELAB)")

ggplot(data, aes(x = color_R_normalized, y = color_G_normalized, color = rgb(color_R_normalized, color_G_normalized, color_B_normalized))) +
  geom_point(size = 3) +
  scale_color_identity() +
  theme_minimal() +
  labs(title = "Diversidad de Tonalidades en Frutos de Cranberry",
       x = "R Normalizado",
       y = "G Normalizado") +
  theme_minimal()

# Aplicar la conversión a cada fila
Lab <- data %>% select(color_L_median, color_a_median, color_b_median) %>%
  rename(L = color_L_median, a = color_a_median, b = color_b_median)

srgb <- convertColor(Lab, from = 'Lab', 'sRGB', clip = NA) 
colnames(srgb) <- c('R','G','B')

# Graficar los colores usando los valores RGB calculados
ggplot(srgb, aes(x = R, y = G, color = rgb(R, G, B))) +
  geom_point(size = 3) +
  scale_color_identity() +
  theme_minimal() +
  labs(title = "Diversidad de Tonalidades en Frutos de Cranberry",
       x = "R Normalizado",
       y = "G Normalizado") +
  theme_minimal()

### Correlation Matrix
df <- data %>% select(-dir, -berry) %>%
  mutate(filename=gsub('(^.*)(.jpg$)','\\1',filename)) %>%
  group_by(filename) %>%
  summarise(Length = mean(length_cm), 
            Width = mean(width_cm),
            Length_vs_Width = mean(length_vs_width),
            Area = mean(area_cm2), 
            Perimeter = mean(perimeter_cm),
            Solidity = mean(solidity),
            Roundness = mean(roundness),
            Volume = mean(est_volume_cm3),
            Surfarea = mean(est_surfarea_cm2),
            Center = mean(center_px_x),
            Color_L = mean(color_L_median),
            Color_a = mean(color_a_median),
            Color_b = mean(color_b_median),
            Color_R = mean(color_R_median),
            Color_B = mean(color_B_median),
            Color_G = mean(color_G_median)) %>% 
  column_to_rownames('filename') %>% 
  na.omit()

# Calculate the correlation
cormat <- cor(as.matrix(df))

get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}

upper_tri <- get_upper_tri(cormat)

reorder_cormat <- function(cormat){
  # Use correlation between variables as distance
  dd <- as.dist((1-cormat)/2)
  hc <- hclust(dd)
  cormat <-cormat[hc$order, hc$order]
}

# Reorder the correlation matrix
cormat <- reorder_cormat(cormat)

upper_tri <- get_upper_tri(cormat)
# Melt the correlation matrix
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Create a ggheatmap
ggheatmap <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  scale_fill_viridis_c(option = "D", direction = -1, name = "Pearson\nCorrelation") +
  coord_fixed() + 
  geom_text(aes(Var2, Var1, label = round(value, 2), 
                color = ifelse(value > 0.4, "white", "black")), 
            size = 4) +
  scale_color_manual(values = c("black", "white")) + # Define the color scale
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    #panel.grid.major = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.justification = c(1, 0),
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal") +
  guides(fill = guide_colorbar(barwidth = 7, barheight = 1,
                               title.position = "top", title.hjust = 0.5),
         color = "none") # Hide color legend for text colors
ggheatmap

# Create a ggheatmap
ggheatmapV2 <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  scale_fill_viridis_c(option = "D", direction = -1, name = "Pearson\nCorrelation") +
  coord_fixed() + 
  geom_text(aes(Var2, Var1, label = ifelse(abs(value) > 0.4, round(value, 2), "")),
            color = ifelse(melted_cormat$value > 0.5, "white", "black"),
            size = 4) +
  scale_color_manual(values = c("black", "white")) + # Define the color scale
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.justification = c(1, 0),
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal") +
  guides(fill = guide_colorbar(barwidth = 7, barheight = 1,
                               title.position = "top", title.hjust = 0.5),
         color = "none") # Hide color legend for text colors
ggheatmapV2
