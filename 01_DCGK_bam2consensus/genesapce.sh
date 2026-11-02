#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=200G 
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --open-mode=append
#SBATCH --output="job.genespace.%J.out"
#SBATCH --job-name="genespace"


module load r
module load micromamba/1.4.2-7jjmfkf
eval "$(micromamba shell hook --shell=bash)"
micromamba activate /path/to/USER_ROOT/00_BioinformaticTools/envs/orthofinder_env

Rscript genesapce.R

# grep '>' /path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/orthofinder/Results_Aug29/Single_Copy_Orthologue_Sequences/*.fa | sort | uniq | cut -d '>' -f2 > ../../../../n19107.txt
