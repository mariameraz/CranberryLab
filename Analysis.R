library(reticulate)

procesar_imagen <- function(image_path, output_csv, output_image_path, ref_width_cm = 5.1, ref_height_cm = 3.8) {
  # Configurar Python
  use_python("/usr/local/bin/python3", required = TRUE)
  
  # Código Python como string
  python_code <- sprintf("
import cv2
import numpy as np
import csv
from matplotlib import pyplot as plt
from scipy.spatial import ConvexHull

# Parámetros
image_path = '%s'
output_csv = '%s'
output_image_path = '%s'
ref_width_cm = %f
ref_height_cm = %f

# Leer la imagen
img = cv2.imread(image_path)

# Validar que la imagen se cargó correctamente
if img is None:
    raise FileNotFoundError(f'No se encontró la imagen en la ruta: {image_path}')

# Detectar el rectángulo amarillo para calcular escala
hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
lower_yellow = np.array([20, 100, 100])
upper_yellow = np.array([30, 255, 255])
yellow_mask = cv2.inRange(hsv, lower_yellow, upper_yellow)
contours, _ = cv2.findContours(yellow_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# Encontrar el rectángulo amarillo más grande
largest_area = 0
reference_rect = None
for contour in contours:
    epsilon = 0.02 * cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, epsilon, True)
    if len(approx) == 4 and cv2.isContourConvex(approx):
        area = cv2.contourArea(approx)
        if area > largest_area:
            largest_area = area
            reference_rect = cv2.boundingRect(approx)

# Calcular escala en píxeles/cm
if reference_rect:
    _, _, ref_width_px, ref_height_px = reference_rect
    px_per_cm_x = ref_width_px / ref_width_cm
    px_per_cm_y = ref_height_px / ref_height_cm
else:
    raise ValueError('No se detectó el rectángulo amarillo para calcular la escala.')

# Procesar frutos y lóculos
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
_, binary = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY_INV)
kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
closed_binary = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)
contours, hierarchy = cv2.findContours(closed_binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

def is_contour_bad(c, min_area=500, min_circularity=0.6, max_circularity=1.2):
    area = cv2.contourArea(c)
    perimeter = cv2.arcLength(c, True)
    if perimeter == 0:
        return True
    circularity = 4 * np.pi * (area / (perimeter * perimeter))
    return area < min_area or not (min_circularity <= circularity <= max_circularity)

filtered_contours = [
    i for i in range(len(contours))
    if hierarchy[0][i][3] == -1 and not is_contour_bad(contours[i])
]

fruit_locus_map = {}
for i in filtered_contours:
    fruit_locus_map[i] = []
    for j in range(len(contours)):
        if hierarchy[0][j][3] == i:
            fruit_locus_map[i].append(j)

min_locus_area = 50
filtered_fruit_locus_map = {
    fruit_idx: [loculus_idx for loculus_idx in loculi if cv2.contourArea(contours[loculus_idx]) > min_locus_area]
    for fruit_idx, loculi in fruit_locus_map.items()
    if len(loculi) > 1
}

# Calcular métricas de lóculos y convertir a cm
results = []
image_with_annotations = img.copy()
sequential_id = 1  # Iniciar el ID secuencial

for fruit_id, loculi in filtered_fruit_locus_map.items():
    n_locules = len(loculi)

    # Calcular el diámetro más largo (convex hull)
    points = contours[fruit_id].reshape(-1, 2)
    hull = ConvexHull(points)
    max_diameter_px = max(
        np.linalg.norm(points[i] - points[j]) for i in hull.vertices for j in hull.vertices
    )
    max_diameter_cm = max_diameter_px / ((px_per_cm_x + px_per_cm_y) / 2)

    if loculi:
        locule_areas_px = [cv2.contourArea(contours[locule]) for locule in loculi]
        locule_areas_cm = [area / (px_per_cm_x * px_per_cm_y) for area in locule_areas_px]
        locule_mean = np.mean(locule_areas_cm)
        locule_sd = np.std(locule_areas_cm, ddof=1)
        locule_cv = (locule_sd / locule_mean) * 100 if locule_mean != 0 else 0
    else:
        locule_mean = locule_sd = locule_cv = 0

    x, y, _, _ = cv2.boundingRect(contours[fruit_id])
    x_cm = x / px_per_cm_x
    y_cm = y / px_per_cm_y

    # Agregar anotaciones a la imagen
    cv2.putText(
        image_with_annotations,
        f'Fruit {sequential_id}: {n_locules}',
        (x, y - 20),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.8,
        (0, 0, 0),
        2,
        cv2.LINE_AA
    )
    cv2.putText(
        image_with_annotations,
        f'D: {max_diameter_cm:.2f}cm',
        (x, y - 60),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.8,
        (0, 0, 0),
        2,
        cv2.LINE_AA
    )

    # Agregar resultados a la tabla
    results.append({
        'Sample_ID': '20-26',
        'ID_Fruit': sequential_id,
        'N_Locules': n_locules,
        'Max_Diameter_cm': max_diameter_cm,
        'Mean_Area_cm2': locule_mean,
        'SD_Area_cm2': locule_sd,
        'CV_Area': locule_cv,
        'Position_X_cm': x_cm,
        'Position_Y_cm': y_cm
    })

    sequential_id += 1  # Incrementar el ID secuencial

# Guardar los resultados en un archivo CSV
with open(output_csv, mode='w', newline='') as file:
    writer = csv.DictWriter(file, fieldnames=['Sample_ID', 'ID_Fruit', 'N_Locules', 'Max_Diameter_cm', 'Mean_Area_cm2', 'SD_Area_cm2', 'CV_Area', 'Position_X_cm', 'Position_Y_cm'])
    writer.writeheader()
    writer.writerows(results)

# Guardar la imagen anotada
cv2.imwrite(output_image_path, image_with_annotations)

# Mostrar mensaje de confirmación
print(f'Resultados guardados en: {output_csv}')
print(f'Imagen anotada guardada en: {output_image_path}')

# Mostrar la imagen anotada
plt.figure(figsize=(15, 15))
plt.imshow(cv2.cvtColor(image_with_annotations, cv2.COLOR_BGR2RGB))
plt.title('Imagen Anotada con IDs, Número de Lóculos y Diámetro')
plt.axis('off')
plt.show()
", image_path, output_csv, output_image_path, ref_width_cm, ref_height_cm)
  
  # Ejecutar el código Python
  py_run_string(python_code)
}

# Uso de la función
procesar_imagen(
  image_path = "/Users/alejandra/Documents/GitHub/CranberryLab/External_structure/PDF/Stamp_photos/JPG/pagina_1.jpg",
  output_csv = "/Users/alejandra/Documents/GitHub/CranberryLab/External_structure/PDF/Stamp_photos/JPG/output.csv",
  output_image_path = "/Users/alejandra/Documents/GitHub/CranberryLab/External_structure/PDF/Stamp_photos/JPG/imagen_anotada.png"
)


