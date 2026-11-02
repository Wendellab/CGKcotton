#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200G
#SBATCH --time=3-00:30:00
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.mapcompare.%A_%a.out
#SBATCH --job-name="ref_compare"
#SBATCH --array=11,22,26,31,33,35,36,37,39,40,41,42,46,74,76,78,79,82,83,84,85,89,117,119,121,122,125,126,127,128,132,151,160,162,168,169,170

############################
# paths
############################

DIR=/path/to/CGK_PROJECT/01_trimedreads
OUT=/path/to/CGK_PROJECT/03_gvcfs_vcf_new

REFDIR=/path/to/CGK_PROJECT/00_ref_GCF_0256985451

refs=(
$REFDIR/C1_HAUreference.fasta
$REFDIR/G1_HAUreference.fasta
$REFDIR/G2_CRIreference.fasta
$REFDIR/K2_HAUreference.fasta
)

thr=30

############################
# decode job array (4 refs × 43 samples)
############################

nref=4
nsamp=43

ref_i=$(( (SLURM_ARRAY_TASK_ID - 1) / nsamp ))
sample_i=$(( (SLURM_ARRAY_TASK_ID - 1) % nsamp + 1 ))

ref=${refs[$ref_i]}

file1=$(sed -n ${sample_i}p samplelist.txt)
file2=$(sed -n ${sample_i}p samplelist.txt | sed 's/R1[.]fq/R2\.fq/')
name=$(basename $file1 .R1.fq.gz)

refname=$(basename $ref .fasta)
outprefix=${name}.${refname}

mkdir -p $OUT/{bam,log,stats,coverage}

echo "Sample: $name"
echo "Reference: $refname"

############################
# mapping
############################

module load bwa samtools

bwa mem -t $thr -R "@RG\tID:$name\tSM:$name\tPL:ILLUMINA" \
$ref $DIR/$file1 $DIR/$file2 2> $OUT/log/$outprefix.bwa.log | \
samtools view -bS - > $OUT/bam/$outprefix.bam

############################
# mapping statistics
############################

samtools flagstat $OUT/bam/$outprefix.bam > $OUT/stats/$outprefix.flagstat.txt
samtools stats $OUT/bam/$outprefix.bam > $OUT/stats/$outprefix.stats.txt

############################
# extract quick summary
############################

mapped=$(grep "mapped (" $OUT/stats/$outprefix.flagstat.txt | head -1)

echo -e "${name}\t${refname}\t${mapped}" \
>> $OUT/mapping_summary.tsv