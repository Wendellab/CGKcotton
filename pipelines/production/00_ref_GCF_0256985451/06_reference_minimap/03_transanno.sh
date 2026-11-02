#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200G 
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="job.minimap.%J.out"
#SBATCH --job-name="joint_minimap"

reference=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/D5_T2T_PKUreference.fa
query=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G2_CRIreference.fasta

module load minimap2/2.28-py311-esngxqd

minimap2 -t 30 -cx asm5 --cs \
    $query \
    $reference > D5ref_to_G2ref.paf

module load singularity/1.3.6-py311-nvfjdsj

apptainer exec transanno.sif \
    transanno minimap2chain \
    D5ref_to_G2ref.paf \
    --output D5ref_to_G2ref.chain