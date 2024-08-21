import cv2
import os
import argparse
from ColorCorrectionML import ColorCorrectionML

def process_images_in_directory(input_dir, output_dir):
    # Crear el directorio de salida si no existe
    os.makedirs(output_dir, exist_ok=True)

    # Iterar sobre todos los archivos en el directorio
    for filename in os.listdir(input_dir):
        # Construir la ruta completa al archivo
        file_path = os.path.join(input_dir, filename)

        # Verificar si es un archivo de imagen
        if os.path.isfile(file_path) and filename.lower().endswith(('.jpg', '.jpeg', '.png')):
            process_image(file_path, output_dir)

if __name__ == "__main__":
    # Configurar argparse para manejar los argumentos
    parser = argparse.ArgumentParser(description="Procesa y corrige el color de las imágenes en un directorio.")

    # Argumentos para el directorio de entrada y salida
    parser.add_argument('-i', type=str, help="Directorio de entrada que contiene las imágenes.")
    parser.add_argument('-o', type=str, help="Directorio de salida donde se guardarán las imágenes corregidas.")

    # Parsear los argumentos
    args = parser.parse_args()

    # Procesar todas las imágenes en el directorio dado
    process_images_in_directory(args.input_directory, args.output_directory)
