#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=01:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joboutput/job.n19029.%A_%a.out"
#SBATCH --error="joboutput/job.n19029.%A_%a.err"
#SBATCH --array=1-100

ROOT=/path/to/CGK_PROJECT/04_bam2fasta
# File with gene names
gene_file=$ROOT/n19029.txt


# Load modules
module load parallel/20240822-cvsr3ld

run () {
    gene=$1

    # Get the gene name for this array task
    echo "Processing gene: $gene"
	
	python AMAS.py summary -d dna -f fasta -i $ROOT/00_DCGK_n19029/DCGK_${gene}_aln_trim.fasta -o $ROOT/02_DCGK_alnstat/DCGK_${gene}
}

export ROOT
export -f run

split -n "l/${SLURM_ARRAY_TASK_ID}/100" $gene_file |
    parallel run