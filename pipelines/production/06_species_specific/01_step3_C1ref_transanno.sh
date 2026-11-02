#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=150G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joblog/job.CGK_D5GeneRef5.%J.out"
#SBATCH --job-name="CGK_D5GeneRef"

Dir=/path/to/CGK_PROJECT/06_species_specific/C1_ref/VCF
cd $Dir
mkdir -p merged

#module load picard/2.26.2-ufzi2of

#picard GatherVcfs \
#$(for vcf in *.combined.vcf.gz; do echo -I "$vcf"; done) \
#-O ./merged/$output1.combined.vcf.gz 


bcftools concat -Oz -o merged/C1C2_C1ref.combined.vcf.gz \
C1C2_C1ref.Chr01.combined.vcf.gz \
C1C2_C1ref.Chr02.combined.vcf.gz \
C1C2_C1ref.Chr03.combined.vcf.gz \
C1C2_C1ref.Chr04.combined.vcf.gz \
C1C2_C1ref.Chr05.combined.vcf.gz \
C1C2_C1ref.Chr06.combined.vcf.gz \
C1C2_C1ref.Chr07.combined.vcf.gz \
C1C2_C1ref.Chr08.combined.vcf.gz \
C1C2_C1ref.Chr09.combined.vcf.gz \
C1C2_C1ref.Chr10.combined.vcf.gz \
C1C2_C1ref.Chr11.combined.vcf.gz \
C1C2_C1ref.Chr12.combined.vcf.gz \
C1C2_C1ref.Chr13.combined.vcf.gz



cd $Dir/merged
output1=C1C2_C1ref

reference=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/C1_HAUreference.fasta
query=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G2_CRIreference.fasta

module purge

module load singularity/1.3.6-py311-nvfjdsj

apptainer exec  /path/to/CGK_PROJECT/00_ref_GCF_0256985451/06_reference_minimap/transanno.sif transanno \
liftvcf -m --chain /path/to/CGK_PROJECT/00_ref_GCF_0256985451/06_reference_minimap/C1ref_to_G2ref.chain \
-o $output1.combined.transannoG2.vcf.gz --query $query --reference $reference --vcf $output1.combined.vcf.gz --fail FAILED.$output1.combined.transannoG2.vcf.gz