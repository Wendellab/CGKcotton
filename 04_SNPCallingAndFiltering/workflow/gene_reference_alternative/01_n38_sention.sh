#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=70 
#SBATCH --mem=200G 
#SBATCH --time=3-00:30:00
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.CGKD37.%A_%a.out 
#SBATCH --job-name="makeVCF"
#SBATCH --array=30,35

#for i in {1..38}; do     echo "===== 10988781_${i} =====";     seff 10988781_${i};     echo; done  | grep -B5 -E "State: FAILED|State: TIMEOUT" | grep "=" | sed 's/===== 10988781_//g' | sed "s/ =====//g" | tr "\n" ","
#26,30,35,36
#3, 28, 31, 32, 37

outputdir=/path/to/CGK_PROJECT/03_gvcfs_vcf/
ref=/path/to/CGK_PROJECT/05_genevcf/G2_CRI_generef_n43848.fasta

file1=$(sed -n ${SLURM_ARRAY_TASK_ID}p samplelist_n38.txt)
file2=$(sed -n ${SLURM_ARRAY_TASK_ID}p samplelist_n38.txt | sed 's/R1[.]fq/R2\.fq/')
name=$(basename $file1 .R1.fq.gz)

echo "the first file is " $file1
echo "the second file is " $file2
echo "sample name is" $name

thr=70

#map reads with bwa:
module load bwa
bwa mem -M -R "@RG\tID:$name\tSM:$name\tPL:ILLUMINA" -t $thr $ref $file1 $file2 > /path/to/CGK_PROJECT/05_genevcf/output/$name.sam
module purge 

cd /path/to/CGK_PROJECT/05_genevcf/output/

#scoring with sentieon-genomics:
# Configure Sentieon licensing privately in the execution environment.
module load sentieon-genomics
sentieon util sort -o $name.sort.bam -t $thr --sam2bam -i $name.sam

#extimate stats with sentieon-genomics:
sentieon driver -t $thr -i $name.sort.bam --algo LocusCollector --fun score_info $name.score 
sentieon driver -t $thr -i $name.sort.bam --algo Dedup --rmdup --score_info $name.score --metrics $name.dedup.metric $name.dedup.bam 

#realign with sentieon-genomics:
sentieon driver -t $thr -r $ref -i $name.dedup.bam --algo Realigner $name.realign.bam

#### BELOW IS ME ######
#coverage caculation:
sentieon driver -t $thr -r $ref -i $name.realign.bam --algo CoverageMetrics $name

#Base quality score recalibration:
sentieon driver -t $thr -r $ref -i $name.realign.bam --algo QualCal $name.RECAL_DATA.TABLE

#create gvcf files with sentieon-genomics:
sentieon driver -t $thr -r $ref -i $name.realign.bam -q $name.RECAL_DATA.TABLE --algo Haplotyper $name.gVCF --emit_mode gvcf 

mv $name*.gVCF* /path/to/CGK_PROJECT/05_genevcf/gvcf
mv $name*.sample_summary /path/to/CGK_PROJECT/05_genevcf/coverageoutput

