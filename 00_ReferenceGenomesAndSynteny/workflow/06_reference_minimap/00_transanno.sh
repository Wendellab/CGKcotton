#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200G 
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="job.minimap.%J.out"
#SBATCH --job-name="joint_minimap"


#module load singularity/1.3.6-py311-nvfjdsj
#apptainer pull transanno.sif docker://informationsea/transanno:latest
#apptainer exec transanno.sif transanno --help



reference=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/C1_HAUreference.fasta
query=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G2_CRIreference.fasta


module load minimap2/2.28-py311-esngxqd

minimap2 -t 30 -cx asm5 --cs $query $reference > C1ref_to_G2ref.paf

module load singularity/1.3.6-py311-nvfjdsj

apptainer exec transanno.sif transanno minimap2chain C1ref_to_G2ref.paf --output C1ref_to_G2ref.chain
