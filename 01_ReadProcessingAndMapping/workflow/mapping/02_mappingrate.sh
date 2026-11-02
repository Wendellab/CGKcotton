#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200G
#SBATCH --time=3-00:30:00
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.mapcompare.%A_%a.out
#SBATCH --job-name="ref_compare"

module load bwa samtools

ref=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/D5_T2T_PKUreference.fa
DIR=/path/to/CGK_PROJECT/01_trimedreads
thr=30

# SAMPLE_010
bwa mem -t $thr \
-R "@RG\tID:SAMPLE_010\tSM:SAMPLE_010\tPL:ILLUMINA" \
$ref \
$DIR/SAMPLE_002.R1.fq.gz \
$DIR/SAMPLE_002.R2.fq.gz | \
samtools sort -@ $thr -o bam/SAMPLE_002.sorted.bam

# SAMPLE_011
bwa mem -t $thr \
-R "@RG\tID:SAMPLE_011\tSM:SAMPLE_011\tPL:ILLUMINA" \
$ref \
$DIR/SAMPLE_012.R1.fq.gz \
$DIR/SAMPLE_012.R2.fq.gz | \
samtools sort -@ $thr -o bam/SAMPLE_012.sorted.bam
