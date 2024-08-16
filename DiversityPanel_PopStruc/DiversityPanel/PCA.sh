# Plink
# Filtrado de variantes bialelicas
VCF=/home/zalapa/Documents/CranLab/DiversityPanel_PopStruc/DiversityPanel/DP_VCF_stats/FILTERED_MAF/DP_filtered_V2.vcf.gz

bcftools view -m2 -M2 -v snps $VCF -Oz -o DP_filtered_biallelic.vcf.gz

VCF=/home/zalapa/Documents/CranLab/DiversityPanel_PopStruc/DiversityPanel/DP_VCF_stats/FILTERED_MAF/DP_filtered_biallelic.vcf.gz

# LD prunning
$PLINK --vcf $VCF --double-id --allow-extra-chr \
--set-missing-var-ids @:# \
--rm-dup force-first \
--indep-pairwise 50 10 0.1 --out dp


$PLINK --vcf $VCF --double-id --allow-extra-chr --set-missing-var-ids @:# \
--extract dp.prune.in \
--make-bed --pca --out dp
