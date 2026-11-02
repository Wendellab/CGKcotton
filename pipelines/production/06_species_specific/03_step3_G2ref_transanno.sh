#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=150G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joblog/job.%A_%a.out"
#SBATCH --job-name="G1_G1ref"

Dir=/path/to/CGK_PROJECT/06_species_specific/G2_ref/VCF
output1=G2G3_G1ref

cd $Dir
mkdir -p merged

ml bcftools
bcftools concat -Oz -o merged/$output1.combined.vcf.gz \
$(for vcf in *.combined.vcf.gz; do echo "$vcf"; done)
