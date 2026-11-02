#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=150G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joblog/job.%A_%a.out"
#SBATCH --job-name="CGK_merge_sorted"

Dir=/path/to/CGK_PROJECT/06_species_specific/K2_ref/VCF
output1=K_K2ref

cd $Dir/merged

module load bcftools

# Reference of the INPUT VCF
reference=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/K2_HAUreference.fasta
query=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G2_CRIreference.fasta

# Normalize BEFORE liftover
bcftools norm \
    -m +any \
    -Oz \
    -o $output1.combined.norm.vcf.gz \
    $output1.combined.vcf.gz

module purge
module load singularity/1.3.6-py311-nvfjdsj

apptainer exec /path/to/CGK_PROJECT/00_ref_GCF_0256985451/06_reference_minimap/transanno.sif \
transanno liftvcf \
    -m \
    --chain /path/to/CGK_PROJECT/00_ref_GCF_0256985451/06_reference_minimap/K2ref_G2ref.chain \
    --reference $reference \
    --query $query \
    --vcf $output1.combined.norm.vcf.gz \
    -o $output1.combined.norm.transannoG2.vcf.gz \
    --fail FAILED.$output1.combined.norm.transannoG2.vcf.gz

module purge
module load bcftools

bcftools norm \
    -m +any \
    -Oz \
    -o $output1.combined.norm.transannoG2.norm.vcf.gz \
    $output1.combined.norm.transannoG2.vcf.gz

bcftools sort \
    -Oz \
    -o $output1.combined.norm.transannoG2.norm.sorted.vcf.gz \
    $output1.combined.norm.transannoG2.norm.vcf.gz

bcftools index -t $output1.combined.norm.transannoG2.norm.sorted.vcf.gz