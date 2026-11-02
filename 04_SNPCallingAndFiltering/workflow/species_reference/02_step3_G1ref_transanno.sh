#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=150G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joblog/job.%A_%a.out"
#SBATCH --job-name="G1_G1ref"

Dir=/path/to/CGK_PROJECT/06_species_specific/G1_ref/VCF
output1=G1_G1ref

cd $Dir
mkdir -p merged

ml bcftools
bcftools concat -Oz -o merged/$output1.combined.vcf.gz \
$(for vcf in *.combined.vcf.gz; do echo "$vcf"; done)


cd $Dir/merged

reference=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G1_HAUreference.fasta
query=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G2_CRIreference.fasta

module purge

module load singularity/1.3.6-py311-nvfjdsj

apptainer exec  /path/to/CGK_PROJECT/00_ref_GCF_0256985451/06_reference_minimap/transanno.sif transanno \
liftvcf -m --chain /path/to/CGK_PROJECT/00_ref_GCF_0256985451/06_reference_minimap/G1ref_G2ref.chain \
-o $output1.combined.transannoG2.vcf.gz --query $query --reference $reference --vcf $output1.combined.vcf.gz --fail FAILED.$output1.combined.transannoG2.vcf.gz