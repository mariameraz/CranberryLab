library(EBImage)
library(reticulate)

setwd('~/Documents/GitHub/CranberryLab/External_structure/')

# 1. Cargar la imagen
image <- readImage('PDF/Image_Test.jpg')

# 2. Convertir la imagen a escala de grises
gray <- channel(image, 'gray')

# 3. Invertir la imagen (si es necesario)
inverted <- 1 - gray
display(inverted, title = "Imagen Invertida")

# 4. Suavizar la imagen para reducir ruido (Filtro Gaussiano)
smoothed <- gblur(inverted, sigma = 0.5)  # Ajusta sigma según la cantidad de ruido
display(smoothed, title = "Imagen Suavizada")

# 5. Etiquetar regiones conectadas
labeled <- bwlabel(smoothed > 0.1)  # Umbral binario ajustado
display(colorLabels(labeled), title = "Regiones Etiquetadas")

# 6. Eliminar regiones pequeñas (ruido)
features <- computeFeatures.shape(labeled)
summary(features)
min_area <- 100  # Cambia según el tamaño esperado de los objetos
filtered <- rmObjects(labeled, which(features[, "s.area"] < min_area))  
display(colorLabels(filtered), title = "Regiones Filtradas")

# 7. Verificar las características de las regiones filtradas
features_shape <- computeFeatures.shape(filtered)
features_moment <- computeFeatures.moment(filtered)

# Combinar ambas tablas
features_with_labels <- data.frame(
  Label = as.numeric(rownames(features_shape)),  # Etiquetas de los frutos
  features_shape,  # Características geométricas
  s.cx = features_moment[, "m.cx"],  # Coordenada X del centroide
  s.cy = features_moment[, "m.cy"]   # Coordenada Y del centroide
)


# Crear una copia de la imagen filtrada
labeled_image <- colorLabels(filtered)

# Configurar el archivo de salida
output_path <- "./frutos_etiquetados.png"
png(output_path, width = 800, height = 600)  # Ajusta el tamaño según tus necesidades

# Mostrar la imagen etiquetada con colores
display(labeled_image, method = "raster") 
# Superponer etiquetas
for (i in 1:nrow(features_with_labels)) {
  label <- features_with_labels$Label[i]  # Etiqueta
  x <- features_with_labels$s.cx[i]  # Coordenada X del centroide
  y <- features_with_labels$s.cy[i]  # Coordenada Y del centroide
  
  # Dibujar rectángulo negro detrás del texto
  rect(
    x - 10, y - 10, x + 10, y + 10,
    col = "black", border = NA
  )
  
  # Añadir texto en el centro del rectángulo
  text(
    x, y, labels = as.character(label),
    col = "white", cex = 0.8, font = 2
  )
}

# Guardar y cerrar el dispositivo gráfico
dev.off()

cat("Imagen guardada en:", output_path, "\n")

## Detect the bar
# Etiquetar las regiones conectadas binary <- gray < 0.5  # Ajusta el umbral según sea necesario

# Eliminar ruido (suavizar la imagen)
binary <- gray < 0.8
display(binary)
binary <- opening(binary, makeBrush(5, shape = "disc"))

labeled <- bwlabel(binary)

# Calcular características de las regiones
features_bar_mom <- computeFeatures.moment(labeled)
features_bar_shape <- computeFeatures.shape(labeled)

# Combinar ambas tablas
features_with_labels_bar <- data.frame(
  Label = as.numeric(rownames(features_bar_shape)),  # Etiquetas de los frutos
  features_bar_shape,  # Características geométricas
  s.cx = features_bar_mom[, "m.cx"],  # Coordenada X del centroide
  s.cy = features_bar_mom[, "m.cy"]   # Coordenada Y del centroide
)
# Filtrar regiones rectangulares en la parte inferior de la imagen
# Supongamos que la barra tiene un área y un perímetro grandes
bar_candidate <- which(
  features_with_labels_bar[, "s.area"] > 500 &  # Área mínima de la barra
    features_with_labels_bar[, "s.perimeter"] > 100 &  # Perímetro mínimo
    features_with_labels_bar[, "s.radius.min"] / features_with_labels_bar[, "s.radius.max"] > 0.8  # Relación aspecto casi rectangular
)

# Identificar la región más baja en la imagen
if (length(bar_candidate) > 1) {
  bar_candidate <- bar_candidate[which.max(features_with_labels_bar[bar_candidate, "s.cy"])]  # Más cercana a la parte inferior
}

# Crear la máscara de la barra roja
bar_region <- labeled == bar_candidate

# Mostrar la región detectada
display(colorLabels(bar_region), title = "Barra Roja Detectada")

# Calcular la longitud de la barra en píxeles
bar_length_pixels <- features_with_labels_bar[bar_candidate, "s.perimeter"]

# Calcular píxeles por cm (la barra mide 2 cm)
pixels_per_cm <- bar_length_pixels / 2
cat("Píxeles por cm:", pixels_per_cm, "\n")

## Connect python
use_virtualenv("myenv_ext/")  # Cambia "mi_virtualenv" por tu entorno
py_config()
# Call cv2
cv2 <- import('cv2')
np <- import('numpy')

# Leer la imagen
img <- cv2$imread('PDF/Image_Test.jpg')
if (is.null(img)) {
  stop("La imagen no se pudo cargar. Verifica la ruta del archivo.")
}

# Crear un umbral binario
lowcolor <- tuple(0, 0, 75)
highcolor <- tuple(255, 255, 255)
thresh <- cv2$inRange(img, lowcolor, highcolor)

# Convertir 'thresh' al formato uint8
thresh <- np$uint8(thresh)

# Crear un kernel
kernel <- np$ones(tuple(as.integer(5), as.integer(5)), dtype = np$uint8)

# Aplicar la operación MORPH_CLOSE
thresh <- cv2$morphologyEx(thresh, cv2$MORPH_CLOSE, kernel)

# Detectar contornos
contours <- cv2$findContours(thresh, cv2$RETR_EXTERNAL, cv2$CHAIN_APPROX_SIMPLE)
contours <- if (length(contours) == 2) contours[[1]] else contours[[2]]

# Crear una copia de la imagen original
result <- np$copy(img)

# Dibujar contornos basados en el área
for (c in contours) {
  area <- cv2$contourArea(c)
  if (area > 5000) {
    cv2$drawContours(result, list(c), -1, tuple(0, 255, 0), 2)
  }
}

# Guardar las imágenes procesadas
cv2$imwrite('red_line_thresh.png', thresh)
cv2$imwrite('red_line_extracted.png', result)

cat("Imágenes guardadas: red_line_thresh.png y red_line_extracted.png\n")