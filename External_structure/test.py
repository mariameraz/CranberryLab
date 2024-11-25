import pandas as pd
import cv2
import numpy as np
import argparse
import os


# Variable global para un contador único de frutas
fruit_counter = 1


def process_image(image_path, output_dir):
    """
    Procesa una sola imagen para detectar frutos, calcular estadísticas y guardar la imagen anotada.

    Args:
        image_path (str): Ruta de la imagen a procesar.
        output_dir (str): Directorio donde se guardarán las imágenes anotadas y resultados.
    """
    global fruit_counter  # Usamos una variable global para que el conteo sea único en todas las imágenes

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
        for contour in contours:
            # Calcular el área y el perímetro del contorno
            area = cv2.contourArea(contour)
            perimeter = cv2.arcLength(contour, True)
            if perimeter > 0:  # Prevenir división por cero
                circularity = (4 * np.pi * area) / (perimeter ** 2)
                # Umbral para considerar el contorno como redondo/ovalado y filtrar por área
                if 2000 < area < 200000 and 0.5 < circularity <= 1.2:
                    # Calcular el centroide del contorno
                    M = cv2.moments(contour)
                    if M["m00"] > 0:
                        cX = int(M["m10"] / M["m00"])
                        cY = int(M["m01"] / M["m00"])

                        # Crear una etiqueta única para cada fruta
                        label = f"Fruit_{fruit_counter}"
                        fruit_counter += 1

                        # Dibujar el contorno
                        cv2.drawContours(image_contours, [contour], -1, (0, 255, 0), 2)  # Contorno en verde

                        # Agregar fondo negro translúcido detrás del texto
                        overlay = image_contours.copy()
                        text_size = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.8, 2)[0]
                        # Obtener las dimensiones del texto
                        text_size = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 2, 3)[0]  # Cambia 2 y 3 según el tamaño del texto
                        text_width, text_height = text_size

                        # Calcular el rectángulo de fondo basado en el tamaño del texto
                        margin_x = 15  # Margen horizontal
                        margin_y = 15  # Margen vertical
                        cv2.rectangle(
                            overlay,
                            (cX - margin_x, cY - text_height - margin_y),  # Coordenadas del inicio del rectángulo
                            (cX + text_width + margin_x, cY + margin_y),   # Coordenadas del final del rectángulo
                            (0, 0, 0),  # Color negro
                            -1  # Rellenar el rectángulo
                        )

                        alpha = 0.3  # Opacidad del fondo negro
                        cv2.addWeighted(overlay, alpha, image_contours, 1 - alpha, 0, image_contours)

                        # Agregar el texto en rosa pastel
                        cv2.putText(
                            image_contours,
                            label,
                            (cX - 10, cY - 10),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            2,
                            (203, 192, 255),  # Color rosa pastel en formato BGR
                            2
                        )

                        # Crear una máscara para el contorno actual
                        mask = np.zeros(image.shape[:2], dtype=np.uint8)
                        cv2.drawContours(mask, [contour], -1, 255, -1)

                        # Calcular estadísticas de color para todos los espacios
                        row = {"Image_name": os.path.basename(image_path), "Fruit_label": label}
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

                                # Agregar estadísticas al renglón
                                row[f"{channel_name}_mean"] = mean
                                row[f"{channel_name}_std"] = std
                                row[f"{channel_name}_cv"] = cv

                        results.append(row)

        # Guardar la imagen anotada
        output_image_path = os.path.join(output_dir, f"annotated_{os.path.basename(image_path)}")
        cv2.imwrite(output_image_path, image_contours)
        print(f"Imagen anotada guardada en: {output_image_path}")

        return results
    else:
        print(f"Error: No se pudo cargar la imagen {image_path}. Verifica la ruta.")
        return []


def main():
    parser = argparse.ArgumentParser(description="Procesa una imagen o directorio para detectar frutos y calcular estadísticas de color.")
    parser.add_argument("-i", "--input", required=True, help="Ruta a la carpeta o imagen de entrada.")
    parser.add_argument("-o", "--output", required=True, help="Ruta a la carpeta de salida.")
    args = parser.parse_args()

    input_path = args.input
    output_dir = args.output

    # Crear directorio de salida si no existe
    os.makedirs(output_dir, exist_ok=True)

    all_results = []

    if os.path.isfile(input_path):
        # Procesar una sola imagen
        results = process_image(input_path, output_dir)
        all_results.extend(results)
    elif os.path.isdir(input_path):
        # Procesar todas las imágenes en un directorio
        for file_name in os.listdir(input_path):
            if file_name.lower().endswith(('.png', '.jpg', '.jpeg')):
                results = process_image(os.path.join(input_path, file_name), output_dir)
                all_results.extend(results)
    else:
        print("Error: La ruta de entrada no es válida. Proporcione un archivo o un directorio válido.")
        return

    # Guardar todos los resultados en un solo archivo CSV
    output_csv_path = os.path.join(output_dir, "output_colors.csv")
    df = pd.DataFrame(all_results)
    df.to_csv(output_csv_path, index=False)

    print(f"Resultados guardados en {output_csv_path}")


if __name__ == "__main__":
    main()

