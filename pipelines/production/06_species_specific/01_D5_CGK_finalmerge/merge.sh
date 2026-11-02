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
  -o CGKD_merged_sorted.vcf.gz \
  ../00_finalmerge/C1.dedup.vcf.gz \
  ../00_finalmerge/G1.dedup.vcf.gz \
  ../00_finalmerge/G2G3.noC3-1.dedup.vcf.gz \
  ../00_finalmerge/K2.dedup.vcf.gz \
  D5.dedup.vcf.gz


vcftools \
  --gzvcf CGKD_merged_sorted.vcf.gz \
  --min-alleles 2 \
  --max-alleles 2 \
  --max-missing 0.9 \
  --mac 1 \
  --minDP 5 \
  --remove-indels \
  --recode --recode-INFO-all \
  --out CGKD.biallelic.missing90.mindp5
  
bcftools annotate --set-id +"%CHROM:%POS:%REF:%ALT" CGKD.biallelic.missing90.mindp5.recode.vcf >  CGKD.biallelic.missing90.mindp5.id.vcf
bcftools view -e 'ALT="*"' CGKD.biallelic.missing90.mindp5.id.vcf > CGKD.biallelic.missing90.mindp5.id.altfix.vcf
