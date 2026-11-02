#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --time=10:00:00
#SBATCH --job-name=remove_C3-1
#SBATCH --output=remove_C3-1.%j.out
#SBATCH --mail-type=ALL

module load bcftools

bcftools view \
    -s ^G2aus_C3-1 \
    -Oz \
    -o G2G3.noC3-1.dedup.vcf.gz \
    G2G3.dedup.vcf.gz

bcftools index -t G2G3.noC3-1.dedup.vcf.gz
