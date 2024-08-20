# Create a new environment
conda create --name conda_env_crancnn.yml

# Activate environment
conda activate conda_env_crancnn.yml

# Install packages
conda install plantcv
conda install pytesseract
conda install tqdm
python3 -m pip install torch
pip install ultralytics
pip install segment-anything
pip install --upgrade opencv-python opencv-contrib-python
pip install pyarrow

# Define variables
CRAN=/home/zalapa/Documents/crancv-main_Aug-20-2024/crancv-main/CranExternalV1.py
INPUT=/home/zalapa/Documents/CranLab/DiversityPanel/Phenotyping/Harvest1_2023/Images
ANN=/home/zalapa/Documents/CranLab/DiversityPanel/Phenotyping/Harvest1_2023/Images/Annotated
OUT=/home/zalapa/Documents/CranLab/DiversityPanel/Phenotyping/Harvest1_2023/Images.csv

# Run the analysis with blue background

python3 $CRAN -i $INPUT -o $OUT --cv2 -s 2 --norows --correct -a $ANN -n 10

# --cv2, use cv2 segmentation 
# -s 2, diameter of the dots in cm
# --norows, not sorted berries
# --correct, correct image colors
# -a, save annotated photos


# Deactivate environment
conda deactivate yml_files/conda_env_crancnn.yml
