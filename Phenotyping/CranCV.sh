# Create a new environment
conda create --name mamba_env_bicran.yml

# Activate environment
conda activate mamba_env_bicran.yml

# Install packages
conda install plantcv
conda install pytesseract
conda install tqdm
python3 -m pip install torch
pip install ultralytics
pip install segment-anything

# Activate environment
conda activate yml_files/mamba_env_bicran.yml

# Update environment
mamba env update --file mamba_env_bicran.yml

# Define variables
CRAN=/home/torresmeraz/crancv-main/CranExternalV1.py
INPUT=/home/torresmeraz/Tomomi_test/Images
ANN=/home/torresmeraz/Tomomi_test/Images/Annotated
OUT=/home/torresmeraz/Tomomi_test/Images.csv

# Run the analysis with blue background

python3 $CRAN -i $INPUT -o $OUT --cv2 -s 2 --norows --correct -a $ANN 

# --cv2, use cv2 segmentation 
# -s 2, diameter of the dots in cm
# --norows, not sorted berries
# --correct, correct image colors
# -a, save annotated photos
