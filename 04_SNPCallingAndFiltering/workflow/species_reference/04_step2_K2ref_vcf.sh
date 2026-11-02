#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=150G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joblog/job.CGK_D5GeneRef5.%J.out"
#SBATCH --job-name="CGK_D5GeneRef"
#SBATCH --array=1-13

seq=$(printf %02d ${SLURM_ARRAY_TASK_ID})
echo "$seq"

Dir=/path/to/CGK_PROJECT/06_species_specific/K2_ref/VCF
ref=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/K2_HAUreference.fasta
thr=30 #NUMBER_THREADS

output1=K_K2ref

cd $Dir

module load sentieon-genomics/202308.02-e2gz6fb
# Configure Sentieon licensing privately in the execution environment.

#joint SNP calling:

ls -1 /path/to/CGK_PROJECT/06_species_specific/K2_ref/gvcf/*.gVCF | sentieon driver --interval Chr$seq -t $thr -r $ref --algo GVCFtyper --emit_mode all $TMPDIR/$output1.Chr$seq.vcf -
mv $TMPDIR/$output1.Chr$seq.vcf* $Dir

module load vcftools
vcftools --vcf $output1.Chr$seq.vcf --remove-indels --min-alleles 2 --max-alleles 2 --recode --recode-INFO-all --out  $output1.Chr$seq.variant
vcftools --vcf $output1.Chr$seq.vcf --remove-indels --max-maf 0 --recode --out  $output1.Chr$seq.invariant


module load parallel/20220522-sxcww47

parallel bgzip {} ::: $output1.Chr$seq.*variant.recode.vcf
parallel tabix {} ::: $output1.Chr$seq.*variant.recode.vcf.gz


module purge

module load bcftools/1.22-soo6voh

bcftools concat --allow-overlaps --threads $thr $output1.Chr$seq.variant.recode.vcf.gz $output1.Chr$seq.invariant.recode.vcf.gz -Oz -o $output1.Chr$seq.combined.vcf.gz

tabix $output1.Chr$seq.combined.vcf.gz