import cv2
import numpy as np
import matplotlib.pyplot as plt

plt.switch_backend('TkAgg')

img = cv2.imread('/Users/alejandra/Documents/GitHub/CranberryLab/External_structure/PDF/Image_Test.jpg')

plt.imshow(img)
plt.axis('off')
plt.show