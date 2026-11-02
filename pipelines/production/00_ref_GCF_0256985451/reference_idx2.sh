#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G 
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --open-mode=append
#SBATCH --output="job.refCGK.%J.out"
#SBATCH --job-name="jointrefCGK"

module load bwa/0.7.17-zgotlbn
module load  samtools/1.19.2-py311-qlmoxzv

bwa index D5_T2T_PKUreference.fa
samtools faidx D5_T2T_PKUreference.fa