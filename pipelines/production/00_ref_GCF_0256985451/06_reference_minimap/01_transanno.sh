#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=200G
#SBATCH --time=20:00:00
#SBATCH --mail-type=ALL
#SBATCH --output=job.minimap.%A_%a.out
#SBATCH --job-name=G2_chain
#SBATCH --array=1-2

set -euo pipefail

REFDIR=/path/to/CGK_PROJECT/00_ref_GCF_0256985451

refs=(
G1_HAUreference
K2_HAUreference
)

labels=(
G1ref
K2ref
)

idx=$((SLURM_ARRAY_TASK_ID-1))

reference="${REFDIR}/${refs[$idx]}.fasta"
query="${REFDIR}/G2_CRIreference.fasta"

prefix="${labels[$idx]}_G2ref"

echo "Query: $query"
echo "Reference: $reference"
echo "Output prefix: $prefix"

module load minimap2/2.28-py311-esngxqd

minimap2 \
    -t "${SLURM_CPUS_PER_TASK}" \
    -cx asm5 \
    --cs \
    "$query" \
    "$reference" \
    > "${prefix}.paf"

module load singularity/1.3.6-py311-nvfjdsj

apptainer exec transanno.sif \
    transanno minimap2chain \
    "${prefix}.paf" \
    --output "${prefix}.chain"