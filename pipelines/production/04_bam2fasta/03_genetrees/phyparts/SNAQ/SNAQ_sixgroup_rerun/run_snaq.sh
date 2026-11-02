#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="SNAQ_all.%J.out"
#SBATCH --job-name="SNAQ_all"
set -e

module purge
module load r
module load julia

cd /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/SNAQ/SNAQ_sixgroup_rerun

# All Julia code is in this one file.
julia snaq_all.jl > snaq_all.console.log 2>&1
