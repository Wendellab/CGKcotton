#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=50                # Snakemake controller only
#SBATCH --mem=300G                         # Controller memory only
#SBATCH --time=3-00:00:00                # Match your original runtime
#SBATCH --mail-type=ALL
#SBATCH --output="job.KmerCity.%J.out"
#SBATCH --job-name="KmerCity"

# Load modules
module load snakemake/7.22.0-py310-y4hvhdl
module load singularity/1.1.9-py310-wsbt4ge

cd /path/to/USER_ROOT/00_BioinformaticTools/kmercity

srun --time=72:00:00 \
     --partition=nova \
     --job-name="KmerCity_controller" \
     --output="job.KmerCity_controller.%J.out" \
	 --cpus-per-task=10 \
     --mem=150G \
     --cpu-bind=none \
     snakemake --configfile config/OZconfig_n38.yaml \
	 --use-singularity \
	 --profile slurm \
	 --jobs 40 \
	 --rerun-incomplete

