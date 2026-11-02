#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=150G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="job.CGK_D5GeneRef5.%J.out"
#SBATCH --job-name="CGK_D5GeneRef"

seq=$(printf %02d ${SLURM_ARRAY_TASK_ID})
echo "$seq"

Dir=/path/to/CGK_PROJECT/05_genevcf
ref=/path/to/CGK_PROJECT/05_genevcf/G2_CRI_generef_n43848.fasta
thr=30 #NUMBER_THREADS

output1=CGK_G2ref

cd $Dir
mkdir -p $output1

module load sentieon-genomics/202308.02-e2gz6fb
# Configure Sentieon licensing privately in the execution environment.

#joint SNP calling:

cat list_CGK_G2GeneRef.txt | sentieon driver -t $thr -r $ref --algo GVCFtyper --emit_mode variant $TMPDIR/$output1.vcf -
mv $TMPDIR/$output1.vcf* $Dir/$output1/