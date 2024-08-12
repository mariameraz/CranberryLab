# Esta exploracion puede llevarse a cabo en R (vcfR) o bash (bcftools) 
# Ambos scripts estan en mi GitHub

# Set working directory
cd ~/Documents/CranLab/DiversityPanel_PopStruc

# Create a virtual access to the vcf file
ln -s ~/VACCap/filtered.vcf filtered.vcf #VCF for 470 cranberry individuals and 280603 variants


### Exploring the VCF file

# How many variants do we have? 
bcftools view -H filtered.vcf | wc -l

# Because our VCF is huge, it will be easier to manipulate it if we create an index.
# Compressing out VCF
bgzip filtered.vcf

# Index VCF
bcftools index filtered.vcf.gz

# Declare variables to work with
SUBSET_VCF=~/Documents/CranLab/DiversityPanel_PopStruc/filtered.vcf.gz
OUT=~/Documents/CranLab/DiversityPanel_PopStruc/vcftools/vcf_subset

## Calculate allele frequency (.frq)

vcftools --gzvcf $SUBSET_VCF \ # vcf input
--freq2 \ # Outputs the frequencies without information about the alleles
--out $OUT \ # Output name
--max-alleles 2 # Exclude sites that have more than two alleles.
# Can give you some warnings. That MAY not affect your results (but not 100% sure about it).

## Calculate mean depth per individual (.idepth)
vcftools --gzvcf $SUBSET_VCF --depth --out $OUT

## Calculate mean depth per site (.ldepth)
vcftools --gzvcf $SUBSET_VCF --site-mean-depth --out $OUT


## Calculate site quality (.lqual)
vcftools --gzvcf $SUBSET_VCF --site-quality --out $OUT

## Calculate the proportion of missing data per individual (imiss) (1-0)
vcftools --gzvcf $SUBSET_VCF --missing-indv --out $OUT

## Calculate the proportion of missing data per site (lmiss)
vcftools --gzvcf $SUBSET_VCF --missing-site --out $OUT

## Calculate heterozygosity and inbreed coefficient per individual (.het)
vcftools --gzvcf $SUBSET_VCF --het --out $OUT
# Outputting Individual Heterozygosity: Individual Heterozygosity: Only using biallelic SNPs.



