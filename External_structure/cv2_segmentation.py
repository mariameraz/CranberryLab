import pandas as pd
import cv2
import numpy as np
import argparse
import os
from tqdm import tqdm
from multiprocessing import Pool


def process_single_image(args):
    """
    Procesa una sola imagen para detectar frutos y calcular estadísticas de color.

    Args:
        args (tuple): Argumentos (image_path, output_csv, output_dir).

    Returns:
        list: Lista de resultados para una imagen.
    """
    image_path, output_csv, output_dir = args
    results = []

    # Cargar la imagen
    image = cv2.imread(image_path)
    if image is None:
        print(f"Error: No se pudo cargar la imagen desde {image_path}")
        return results

    # Convertir la imagen original a diferentes espacios de color
    hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    lab_image = cv2.cvtColor(image, cv2.COLOR_BGR2Lab)
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Definir límites del color azul
    lower_blue = np.array([100, 100, 0], dtype=np.uint8)
    upper_blue = np.array([140, 255, 255], dtype=np.uint8)

    # Crear la máscara para detectar los colores azules
    mask_blue = cv2.inRange(hsv_image, lower_blue, upper_blue)

    # Invertir la máscara
    mask_inverted = cv2.bitwise_not(mask_blue)

    # Detectar los contornos en la máscara invertida
    contours, _ = cv2.findContours(mask_inverted, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Crear una copia de la imagen original para visualizar
    image_contours = image.copy()

    # Procesar los contornos
    for idx, contour in enumerate(contours):
        # Calcular el área y el perímetro del contorno
        area = cv2.contourArea(contour)
        perimeter = cv2.arcLength(contour, True)
        if perimeter > 0:  # Prevenir división por cero
            circularity = (4 * np.pi * area) / (perimeter ** 2)
            # Umbral para considerar el contorno como redondo/ovalado y filtrar por área
            if 2000 < area < 200000 and 0.5 < circularity <= 1.2:
                # Dibujar el contorno
                cv2.drawContours(image_contours, [contour], -1, (0, 0, 255), 2)

                # Calcular el centroide del contorno
                M = cv2.moments(contour)
                if M["m00"] > 0:  # Evitar división por cero
                    cX = int(M["m10"] / M["m00"])
                    cY = int(M["m01"] / M["m00"])

                    # Crear una máscara para el contorno actual
                    mask = np.zeros(image.shape[:2], dtype=np.uint8)
                    cv2.drawContours(mask, [contour], -1, 255, -1)

                    # Calcular estadísticas de color
                    stats = {"Image_name": os.path.basename(image_path), "Fruit_number": f"Fruit_{idx + 1}"}
                    for space_name, color_space in [("RGB", image), ("HSV", hsv_image), ("Lab", lab_image), ("Grayscale", gray_image)]:
                        if space_name == "Grayscale":
                            channels = [color_space]
                            channel_names = ["Gray"]
                        else:
                            channels = cv2.split(color_space)
                            channel_names = list("RGB" if space_name == "RGB" else "HSV" if space_name == "HSV" else "Lab")

                        for channel, channel_name in zip(channels, channel_names):
                            values = channel[mask == 255]
                            stats[f"{channel_name}_mean"] = np.mean(values) if len(values) > 0 else None
                            stats[f"{channel_name}_median"] = np.median(values) if len(values) > 0 else None
                            stats[f"{channel_name}_Std"] = np.std(values) if len(values) > 0 else None
                            stats[f"{channel_name}_CV"] = (np.std(values) / np.mean(values) * 100) if len(values) > 0 and np.mean(values) != 0 else None
                    results.append(stats)

                    # Dibujar el texto en rosa pastel sobre un rectángulo negro translúcido
                    overlay = image_contours.copy()
                    text_size = cv2.getTextSize(f"Fruit_{idx + 1}", cv2.FONT_HERSHEY_SIMPLEX, 2, 3)[0]
                    text_width, text_height = text_size
                    cv2.rectangle(
                        overlay,
                        (cX - 15, cY - text_height - 20),
                        (cX + text_width + 15, cY + 10),
                        (0, 0, 0),
                        -1
                    )
                    alpha = 0.3
                    cv2.addWeighted(overlay, alpha, image_contours, 1 - alpha, 0, image_contours)
                    cv2.putText(
                        image_contours,
                        f"Fruit_{idx + 1}",
                        (cX - 10, cY - 10),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        2,
                        (203, 192, 255),
                        3
                    )

    # Guardar la imagen anotada
    output_image_path = os.path.join(output_dir, f"annotated_{os.path.basename(image_path)}")
    cv2.imwrite(output_image_path, image_contours)

    return results


def process_images(input_dir, output_csv, output_dir, threads):
    """
    Procesa imágenes en un directorio utilizando múltiples hilos.

    Args:
        input_dir (str): Directorio de entrada con las imágenes.
        output_csv (str): Archivo CSV para guardar resultados.
        output_dir (str): Directorio para guardar imágenes anotadas.
        threads (int): Número de hilos para procesamiento paralelo.

    Returns:
        None
    """
    # Crear el directorio de salida si no existe
    os.makedirs(output_dir, exist_ok=True)

    # Obtener la lista de imágenes
    image_files = [os.path.join(input_dir, f) for f in os.listdir(input_dir) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]

    # Usar multiprocesamiento para procesar imágenes en paralelo
    with Pool(threads) as pool:
        results = list(tqdm(pool.imap(process_single_image, [(image, output_csv, output_dir) for image in image_files]),
                            total=len(image_files),
                            desc="Procesando imágenes",
                            unit="imagen"))

    # Consolidar todos los resultados y guardarlos en el CSV
    flat_results = [item for sublist in results for item in sublist]
    df = pd.DataFrame(flat_results)
    df.to_csv(output_csv, index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Procesa imágenes para detectar frutos y calcular estadísticas de color.")
    parser.add_argument("-i", "--input", required=True, help="Directorio de entrada con las imágenes.")
    parser.add_argument("-o", "--output", required=True, help="Directorio para guardar imágenes anotadas.")
    parser.add_argument("-c", "--csv", required=True, help="Archivo CSV para guardar resultados.")
    parser.add_argument("-t", "--threads", type=int, default=1, help="Número de hilos para procesamiento paralelo (por defecto: 1).")
    args = parser.parse_args()

    process_images(args.input, args.csv, args.output, args.threads)
