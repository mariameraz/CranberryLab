# Load libraries
library(ggplot2)
library(tidyverse)


# Load data
data <- read.csv('/home/zalapa/Documents/CranLab/Harvest/Harvest1_2023/Images/DPH1_2023.csv', header = T)


data$color_L_median <- (data$color_L_median*100)/255
summary(data$color_L_median)

head(data)

# Normalizar los valores de color RGB
data$color_R_normalized <- data$color_R_median / 255
data$color_G_normalized <- data$color_G_median / 255
data$color_B_normalized <- data$color_B_median / 255

# Filtrar los colores predominantemente rojos
threshold <- 0.5  # Ajusta este umbral según sea necesario
data_red <- data[
  data$color_R_normalized > threshold & 
    data$color_R_normalized > data$color_G_normalized &
    data$color_R_normalized > data$color_B_normalized, 
]

# Crear el gráfico de puntos
ggplot(data_red, aes(x = color_R_normalized, 
                     y = color_G_normalized, 
                     color = rgb(color_R_normalized, color_G_normalized, color_B_normalized))) +
  geom_point(size = 3) +
  scale_color_identity() +
  theme_minimal() +
  labs(title = "Colores Predominantemente Rojos",
       x = "R Normalizado",
       y = "G Normalizado")

# Instalar y cargar ggplot2 si no está ya instalado
install.packages("ggplot2")
library(ggplot2)

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

ggplot(data_red, aes(x = color_R_normalized, y = color_G_normalized, color = rgb(color_R_normalized, color_G_normalized, color_B_normalized))) +
  geom_point(size = 3) +
  scale_color_identity() +
  theme_minimal() +
  labs(title = "Diversidad de Tonalidades en Frutos de Cranberry",
       x = "R Normalizado",
       y = "G Normalizado") +
  theme_minimal()
