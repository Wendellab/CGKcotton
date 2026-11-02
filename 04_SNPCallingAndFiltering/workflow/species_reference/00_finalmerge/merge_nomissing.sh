#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joblog/job.%A_%a.out"
#SBATCH --job-name="CGK_merge_sorted"


module load bcftools vcftools

vcftools \
  --gzvcf CGK_merged_sorted.vcf.gz \
  --min-alleles 2 \
  --max-alleles 2 \
  --max-missing 1 \
  --mac 1 \
  --minDP 5 \
  --remove-indels \
  --recode --recode-INFO-all \
  --out CGK.nomissing.mindp5

bcftools annotate \
  --set-id +"%CHROM:%POS:%REF:%ALT" \
  CGK.nomissing.mindp5.recode.vcf \
  -o CGK.nomissing.mindp5.id.vcf

bcftools view -e 'ALT="*"' \
  CGK.nomissing.mindp5.id.vcf \
  -o CGK.nomissing.mindp5.clean.vcf
