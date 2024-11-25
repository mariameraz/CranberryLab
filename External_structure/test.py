import pandas as pd
import cv2
import numpy as np
import argparse
import os
import matplotlib.pyplot as plt


def process_image(image_path, output_dir):
    """
    Procesa una sola imagen para detectar frutos y calcular estadísticas de color.

    Args:
        image_path (str): Ruta de la imagen a procesar.
        output_dir (str): Directorio donde se guardarán las imágenes anotadas y resultados.
    """
    # Crear una lista para guardar los resultados
    results = []

    # Cargar la imagen
    image = cv2.imread(image_path)

    if image is not None:
        # Convertir la imagen original a diferentes espacios de color
        hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        lab_image = cv2.cvtColor(image, cv2.COLOR_BGR2Lab)
        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        # Definir límites del color azul
        lower_blue = np.array([100, 150, 0], dtype=np.uint8)
        upper_blue = np.array([140, 255, 255], dtype=np.uint8)

        # Crear la máscara para detectar los colores azules
        mask_blue = cv2.inRange(hsv_image, lower_blue, upper_blue)

        # Invertir la máscara
        mask_inverted = cv2.bitwise_not(mask_blue)

        # Detectar los contornos en la máscara invertida
        contours, _ = cv2.findContours(mask_inverted, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        # Crear una copia de la imagen original para visualizar
        image_contours = image.copy()

        # Filtrar contornos redondos/ovalados y dibujarlos con etiquetas
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
                    if M["m00"] > 0:
                        cX = int(M["m10"] / M["m00"])
                        cY = int(M["m01"] / M["m00"])

                        # Poner el identificador (e.g., "fruit_1") en la imagen
                        label = f"fruit_{idx + 1}"

                        # Crear una máscara para el contorno actual
                        mask = np.zeros(image.shape[:2], dtype=np.uint8)
                        cv2.drawContours(mask, [contour], -1, 255, -1)

                        # Calcular estadísticas de color
                        for space_name, color_space in [("RGB", image), ("HSV", hsv_image), ("Lab", lab_image), ("Grayscale", gray_image)]:
                            if space_name == "Grayscale":
                                channels = [color_space]
                                channel_names = ["Gray"]
                            else:
                                channels = cv2.split(color_space)
                                channel_names = list("RGB" if space_name == "RGB" else "HSV" if space_name == "HSV" else "Lab")

                            for channel, channel_name in zip(channels, channel_names):
                                values = channel[mask == 255]
                                mean = np.mean(values)
                                std = np.std(values)
                                cv = (std / mean) * 100 if mean != 0 else 0

                                # Agregar los resultados al CSV
                                results.append({
                                    "Image_name": os.path.basename(image_path),
                                    "Fruit_number": idx + 1,
                                    f"{channel_name}_mean": mean,
                                    f"{channel_name}_Std": std,
                                    f"{channel_name}_CV": cv
                                })

                        # Dibujar el texto en rosa pastel sobre un rectángulo negro translúcido
                        overlay = image_contours.copy()
                        text_size = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 2, 3)[0]
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
                            label,
                            (cX - 10, cY - 10),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            2,
                            (203, 192, 255),
                            3
                        )

        # Guardar la imagen anotada
        output_image_path = os.path.join(output_dir, os.path.basename(image_path))
        cv2.imwrite(output_image_path, image_contours)

        # Guardar los resultados en un CSV
        output_csv_path = os.path.join(output_dir, "output_colors.csv")
        df = pd.DataFrame(results)
        df.to_csv(output_csv_path, index=False)

        print(f"Procesado {image_path}. Resultados guardados en {output_csv_path}")
    else:
        print(f"Error: No se pudo cargar la imagen {image_path}. Verifica la ruta.")


def main():
    parser = argparse.ArgumentParser(description="Procesa una imagen o directorio para detectar frutos y calcular estadísticas de color.")
    parser.add_argument("-i", "--input", required=True, help="Ruta a la carpeta o imagen de entrada.")
    parser.add_argument("-o", "--output", required=True, help="Ruta a la carpeta de salida.")
    args = parser.parse_args()

    input_path = args.input
    output_dir = args.output

    # Crear directorio de salida si no existe
    os.makedirs(output_dir, exist_ok=True)

    if os.path.isfile(input_path):
        # Procesar una sola imagen
        process_image(input_path, output_dir)
    elif os.path.isdir(input_path):
        # Procesar todas las imágenes en un directorio
        for file_name in os.listdir(input_path):
            if file_name.lower().endswith(('.png', '.jpg', '.jpeg')):
                process_image(os.path.join(input_path, file_name), output_dir)
    else:
        print("Error: La ruta de entrada no es válida. Proporcione un archivo o un directorio válido.")


if __name__ == "__main__":
    main()

