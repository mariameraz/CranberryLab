import cv2
import os
import argparse
from tqdm import tqdm  # Para la barra de progreso
from ColorCorrectionML import ColorCorrectionML

# Función para registrar mensajes en un archivo
def log_message(message, log_file="output.txt"):
    with open(log_file, "a") as f:
        f.write(message + "\n")

# Función para procesar y corregir una imagen
def process_image(image_path, output_dir, log_file):
    # Cargar la imagen
    img = cv2.imread(image_path)

    # Crear una instancia de la clase ColorCorrectionML
    color_correction = ColorCorrectionML(img)

    # Intentar detectar y extraer el ColorChecker
    try:
        src0, _, patch_size = color_correction.extract_color_chart()
        if src0 is None:
            log_message(f"Error: No se detectó el ColorChecker en la imagen {os.path.basename(image_path)}.", log_file)
            return
    except Exception as e:
        log_message(f"Error procesando el ColorChecker en la imagen {os.path.basename(image_path)}: {e}", log_file)
        return

    # Calcular la corrección de color
    color_correction.compute_correction()

    # Intentar registrar DeltaE inicial
    try:
        delta_e = getattr(color_correction, 'initial_mean_delta_e', None)
        if delta_e is not None:
            muestra = os.path.basename(image_path).split('.')[0]  # Nombre de la muestra (sin extensión)
            log_message(f"{muestra}: DeltaE {delta_e:.2f}", log_file)
        else:
            log_message(f"Error: No se pudo obtener el DeltaE para la imagen {os.path.basename(image_path)}.", log_file)
    except Exception as e:
        log_message(f"Error al calcular el DeltaE para la imagen {os.path.basename(image_path)}: {e}", log_file)

    # Obtener la imagen corregida
    img_corrected = color_correction.correct_img(img)

    # Guardar la imagen corregida
    filename = os.path.basename(image_path)
    output_path = os.path.join(output_dir, f'corrected_{filename}')
    cv2.imwrite(output_path, img_corrected)

# Función para procesar todas las imágenes en un directorio
def process_images_in_directory(input_dir, output_dir, log_file):
    # Crear el directorio de salida si no existe
    os.makedirs(output_dir, exist_ok=True)

    # Limpiar el archivo de registro al inicio
    open(log_file, "w").close()

    # Obtener una lista de los archivos de imagen
    image_files = [f for f in os.listdir(input_dir) if os.path.isfile(os.path.join(input_dir, f)) and f.lower().endswith(('.jpg', '.jpeg', '.png'))]

    total_files = len(image_files)  # Número total de imágenes

    # Barra de progreso con tqdm
    with tqdm(total=total_files, desc="Procesando imágenes", unit="imagen") as pbar:
        for filename in image_files:
            # Construir la ruta completa al archivo
            file_path = os.path.join(input_dir, filename)

            # Procesar la imagen
            process_image(file_path, output_dir, log_file)

            # Actualizar la barra de progreso
            pbar.update(1)

if __name__ == "__main__":
    # Configurar argparse para manejar los argumentos
    parser = argparse.ArgumentParser(description="Procesa y corrige el color de las imágenes en un directorio.")

    # Agregar las opciones con nombres cortos y largos
    parser.add_argument('-I', '--input_directory', type=str, required=True,
                        help="Directorio de entrada que contiene las imágenes.")
    parser.add_argument('-O', '--output_directory', type=str, required=True,
                        help="Directorio de salida donde se guardarán las imágenes corregidas.")
    parser.add_argument('-L', '--log_file', type=str, default="output.txt",
                        help="Archivo donde se registrarán los resultados del DeltaE.")

    # Parsear los argumentos
    args = parser.parse_args()

    # Procesar todas las imágenes en el directorio dado
    process_images_in_directory(args.input_directory, args.output_directory, args.log_file)
