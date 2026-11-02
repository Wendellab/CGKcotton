#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200G
#SBATCH --time=20:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="job.minimap.%J.out"
#SBATCH --job-name="B1_minimap"

reference=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/B1.genome.chr.fa
query=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G2_CRIreference.fasta

module load bwa/0.7.17-zgotlbn
module load  samtools/1.19.2-py311-qlmoxzv

bwa index $reference
samtools faidx $reference

module purge
module load minimap2/2.28-py311-esngxqd

minimap2 -t 30 -cx asm5 --cs \
    $query \
    $reference > B1ref_to_G2ref.paf

module load singularity/1.3.6-py311-nvfjdsj

apptainer exec transanno.sif \
    transanno minimap2chain \
    B1ref_to_G2ref.paf \
    --output B1ref_to_G2ref.chain