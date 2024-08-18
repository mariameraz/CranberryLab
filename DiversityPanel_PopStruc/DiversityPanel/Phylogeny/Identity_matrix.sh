# Filogenia

PLINK=/home/zalapa/Documents/plink2_linux_x32_64_20240625/plink2
VCF=/home/zalapa/Documents/CranLab/DiversityPanel_PopStruc/DiversityPanel/DP_VCF_stats/FILTERED_MAF/DP_filtered_biallelic.vcf.gz

$PLINK --vcf $VCF --export ped --out output

$PLINK --vcf $VCF --make-rel square --out identity_matrix
