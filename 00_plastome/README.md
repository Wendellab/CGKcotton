#### 1.1 Download data from NCBI 
```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --output="joboutput/job.vcf.%J.out"
#SBATCH --job-name="Moving"
#SBATCH --array=1-21

dir=$(pwd)
file=$dir/srrlist.sh

sampledata=$(cat $file | sed -n ${SLURM_ARRAY_TASK_ID}p)
echo "Samplebam = " $sampledata

module load  sra-tools

prefetch $sampledata --max-size 100G
fasterq-dump --threads 10 --split-files $sampledata/$sampledata.sra
gzip $sampledata*.fastq
```

#### 1.2 Trim the rawreads 
```
#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=30 
#SBATCH --mem=200G 
#SBATCH --time=2-00:30:00
#SBATCH --mail-user=weixuan@iastate.edu
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.trim.%A_%a.out 
#SBATCH --job-name="trim"
#SBATCH --array=22-41

DIR=/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_rawreads
tDir=/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/01_trimedreads
thr=30

file1=$(sed -n ${SLURM_ARRAY_TASK_ID}p filename2.txt | cut -f1)
file2=$(sed -n ${SLURM_ARRAY_TASK_ID}p filename2.txt | cut -f1 | sed 's/_1[.]fastq/_2\.fastq/' | sed 's/_1[.]fq/_2\.fq/')

newname=$(sed -n ${SLURM_ARRAY_TASK_ID}p filename2.txt | cut -f2)

echo "the first file is " $file1
echo "the second file is " $file2
echo "new name is" $newname

#trim reads with Trimmomatic:
module load  trimmomatic/0.39-zwxnnrx
cd $TMPDIR/
trimmomatic PE -threads $thr $file1 $file2 $TMPDIR/$newname.R1.fq.gz $TMPDIR/$newname.U1.fq.gz $TMPDIR/$newname.R2.fq.gz $TMPDIR/$newname.U2.fq.gz ILLUMINACLIP:/lustre/hdd/LAS/jfw-lab/weixuan/03_Ggvcf/Adapters.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:75

mv $TMPDIR/$newname.R1.fq.gz $tDir
mv $TMPDIR/$newname.R2.fq.gz $tDir

module purge
```

#### 1.3 Running getorgenlle 
```
#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=80 
#SBATCH --mem=200G 
#SBATCH --time=10:00:00
#SBATCH --mail-user=weixuan@iastate.edu
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.makePR.%A_%a.out 
#SBATCH --job-name="getorganelle"
#SBATCH --array=13

module load getorganelle/1.7.7.0-py310-u45ybv3
DIR=/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/01_trimedreads
outputDIR=/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/02_getorg

file1=$(sed -n ${SLURM_ARRAY_TASK_ID}p samplelist.txt)
file2=$(sed -n ${SLURM_ARRAY_TASK_ID}p samplelist.txt | sed 's/R1[.]fq/R2\.fq/')
name=$(basename $file1 .R1.fq.gz)

echo "the first file is " $file1
echo "the second file is " $file2
echo "sample name is" $name

thr=80
get_organelle_from_reads.py -t $thr -1 $file1 -2 $file2 -o $outputDIR/01_plastome_output/$name -k 21,45,65,85,109,115 -R 10 -F embplant_pt --overwrite

# Add reference plastome, change kmer length and increace round of assmbely to improve samples without complete plastome assmbeled.
# get_organelle_from_reads.py -t $thr -s /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/02_getorg/change_all_aln_selected_fix.fasta -1 $file1 -2 $file2 -o $outputDIR/01_plastome_output/$name -k 21,45,65,85,109,115 -R 20 --max-reads 536870910 -F embplant_pt --overwrite
```

#### 1.4 Map to consensus to get plastome using K1 as reference for K6, K9, etc plastome extractios.
```
#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=80 
#SBATCH --mem=200G 
#SBATCH --time=10:30:00
#SBATCH --mail-user=weixuan@iastate.edu
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.cultivar.%A_%a.out 
#SBATCH --job-name="makeVCF"
#SBATCH --array=1-6

thr=80
ref=embplant_pt.K85.complete.graph1.1.path_sequence.fasta
readdir=/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/01_trimedreads

#cp /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/02_getorg/01_plastome_output/K1_SRR3560141_set1/K1_SRR3560141_set1/embplant_pt.K85.complete.graph1.1.path_sequence.fasta ./
#sed -i 's/^>.*/>K1/' $ref

file1=$(sed -n ${SLURM_ARRAY_TASK_ID}p samplelist.txt)
file2=$(sed -n ${SLURM_ARRAY_TASK_ID}p samplelist.txt | sed 's/R1[.]fq/R2\.fq/')
name=$(basename $file1 .R1.fq.gz)

module load bwa
module load vcftools bcftools
#samtools faidx embplant_pt.K85.complete.graph1.1.path_sequence.fasta
#bwa index embplant_pt.K85.complete.graph1.1.path_sequence.fasta 
bwa mem -M -R "@RG\tID:$name\tSM:$name\tPL:ILLUMINA" -t 80 embplant_pt.K85.complete.graph1.1.path_sequence.fasta $file1 $file2 > $name.sam

export SENTIEON_LICENSE=reimu.las.iastate.edu:8990
module load sentieon-genomics
sentieon util sort -o $name.sort.bam -t $thr --sam2bam -i $name.sam

#scoring with sentieon-genomics:
export SENTIEON_LICENSE=reimu.las.iastate.edu:8990
module load sentieon-genomics
sentieon util sort -o $name.sort.bam -t $thr --sam2bam -i $name.sam

#extimate stats with sentieon-genomics:
sentieon driver -t $thr -i $name.sort.bam --algo LocusCollector --fun score_info $name.score 
sentieon driver -t $thr -i $name.sort.bam --algo Dedup --rmdup --score_info $name.score --metrics $name.dedup.metric $name.dedup.bam 

#realign with sentieon-genomics:
sentieon driver -t $thr -r $ref -i $name.dedup.bam --algo Realigner $name.realign.bam

bcftools mpileup -Ou -f $ref $name.realign.bam | bcftools call -mv -Oz -o $name.vcf.gz
bcftools index $name.vcf.gz

bcftools norm -f $ref $name.vcf.gz -Ov -o $name.norm.vcf

bcftools filter --IndelGap 5 -e 'QUAL<40' $name.norm.vcf -Ov -o $name.norm.flt.vcf

bgzip $name.norm.flt.vcf
tabix $name.norm.flt.vcf.gz

cat $ref | bcftools consensus $name.norm.flt.vcf.gz > $name.fasta
```
