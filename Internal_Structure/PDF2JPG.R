library(pdftools)
library(magick)

setwd('~/Documents/GitHub/CranberryLab/External_structure/PDF')
# Ruta del archivo PDF original
input_pdf <- "lalo11.PDF"

# Extraer todas las páginas como texto o imágenes
total_pages <- pdf_length(input_pdf)

for (i in 1:total_pages) {
  output_pdf <- sprintf("Stamp_photos/pagina_%d.pdf", i)
  pdf_subset(input_pdf, pages = i, output = output_pdf)
}


# Convert pdf to jpg

# Carpeta donde están los PDFs
input_dir <- "~/Documents/GitHub/CranberryLab/External_structure/PDF/Stamp_photos/"  # Cambia a la carpeta con tus PDFs
output_dir <- "~/Documents/GitHub/CranberryLab/External_structure/PDF/Stamp_photos/JPG"  # Cambia a la carpeta donde quieres guardar las imágenes
dir.create(output_dir, recursive = TRUE)  # Crea la carpeta de salida si no existe

# Listar todos los archivos PDF en la carpeta
pdf_files <- list.files(input_dir, pattern = "\\.pdf$", full.names = TRUE)

# Procesar cada PDF
for (pdf in pdf_files) {
  # Crear el nombre del archivo de salida
  output_image <- file.path(output_dir, paste0(tools::file_path_sans_ext(basename(pdf)), ".jpg"))
  
  # Leer el PDF y convertirlo en una imagen
  image <- image_read_pdf(pdf, density = 300)  # Cambia 'density' si necesitas más o menos resolución
  
  # Guardar la imagen como JPG
  image_write(image, path = output_image, format = "jpg")
}

