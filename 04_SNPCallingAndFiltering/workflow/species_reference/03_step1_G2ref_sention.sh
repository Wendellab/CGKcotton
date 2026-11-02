#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=30 
#SBATCH --mem=200G 
#SBATCH --time=1-00:30:00
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.CGKD37.%A_%a.out 
#SBATCH --job-name="makeVCF"
#SBATCH --array=1-7

#grep "/G[23].*.G2" 00_bamlist.txt | grep -v "SAMPLE_014" > 03_G2refbamlist.txt

outputdir=/path/to/CGK_PROJECT/06_species_specific/
ref=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G2_CRIreference.fasta


line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_G2refbamlist.txt)
name=$(basename "$line" .bam)
echo $line
echo "sample name is" $name

thr=30

cd $TMPDIR

#scoring with sentieon-genomics:
# Configure Sentieon licensing privately in the execution environment.
module load sentieon-genomics
sentieon util sort -o $name.sort.bam -t $thr -i $line

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


cd $outputdir
mkdir -p G2_ref
cd G2_ref
mkdir -p gvcf
mkdir -p coverageoutput
mkdir -p VCF

mv $TMPDIR/$name*.gVCF* /path/to/CGK_PROJECT/06_species_specific/G2_ref/gvcf
mv $TMPDIR/$name*.sample_summary /path/to/CGK_PROJECT/06_species_specific/G2_ref/coverageoutput

