#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=150G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joblog/job.%A_%a.out"
#SBATCH --job-name="CGK_merge_sorted"


module load bcftools vcftools

bcftools merge \
  -m all \
  -Oz \
  -o CGK_merged_sorted.vcf.gz \
  C1.dedup.vcf.gz \
  G1.dedup.vcf.gz \
  G2G3.noC3-1.dedup.vcf.gz \
  K2.dedup.vcf.gz 

vcftools \
  --gzvcf CGK_merged_sorted.vcf.gz \
  --min-alleles 2 \
  --max-alleles 2 \
  --max-missing 0.9 \
  --mac 1 \
  --minDP 5 \
  --remove-indels \
  --recode --recode-INFO-all \
  --out CGK.biallelic.missing90.mindp5
  
bcftools annotate --set-id +"%CHROM:%POS:%REF:%ALT" CGK.biallelic.missing90.mindp5.recode.vcf >  CGK.biallelic.missing90.mindp5.id.vcf
bcftools view -e 'ALT="*"' CGK.biallelic.missing90.mindp5.id.vcf > CGK.biallelic.missing90.mindp5.id.altfix.vcf

# Missingness per individual
vcftools \
    --gzvcf CGK.biallelic.missing90.mindp5.id.altfix.vcf \
    --missing-indv \
    --out final

# Missingness per site
vcftools \
    --gzvcf CGK.biallelic.missing90.mindp5.id.altfix.vcf \
    --missing-site \
    --out final