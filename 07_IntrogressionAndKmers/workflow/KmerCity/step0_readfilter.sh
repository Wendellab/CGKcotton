#!/bin/bash
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=100G 
#SBATCH --time=10:00:00
#SBATCH --mail-type=ALL
#SBATCH --output=joblog/job.kmercity.%A_%a.out 
#SBATCH --job-name="kmercity"
#SBATCH --array=1-38

#ls -1 $PWD/*.R1.fq.gz | grep -v -E "D5|G2aus_C3-1|SAMPLE_015|SAMPLE_014" > ../07_Kmer/list_CGK_n38.txt

DIR=/path/to/CGK_PROJECT/07_Kmer
thr=20

file1=$(sed -n ${SLURM_ARRAY_TASK_ID}p list_CGK_n38.txt)
file2=$(sed -n ${SLURM_ARRAY_TASK_ID}p list_CGK_n38.txt | sed 's/R1[.]fq/R2\.fq/')
name=$(basename $file1 .R1.fq.gz)

echo "the first file is " $file1
echo "the second file is " $file2
echo "sample name is" $name

#cat /path/to/USER_ROOT/09_getorgenelle/00_TEX2094/ncbiAD1mtDNA.fasta /path/to/USER_ROOT/09_getorgenelle/00_TEX2094/plastome_output/TX2094-USDA/embplant_pt.K105.complete.graph1.1.path_sequence.fasta > chloro_mito.fasta
#wget "https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08_GB_20251015.tar.gz"
#mkdir -p kraken2db
#tar -xzf k2_standard_08_GB_20251015.tar.gz -C kraken2db

module load kraken2/2.1.2-2kmlv3r

kraken2 $file1 $file2 \
    --paired \
	--db /path/to/USER_ROOT/08_YUCFL_popgene/04_TE/00_readsfilter/kraken2db/ \
    --classified-out ${name}_contaminated#.fastq \
    --unclassified-out ${name}_clean#.fastq \
    --use-names \
    --gzip-compressed \
    --threads $thr \
    --output ${name}_output.txt \
    --report ${name}_report.txt

mkdir -p 00_cleanread
mkdir -p 01_cleanreadreport

mv ${name}_clean_*.fastq 00_cleanread/
mv ${name}_report.txt 01_cleanreadreport

rm ${name}_output.txt
rm ${name}_contaminated_*.fastq

mkdir -p 02_chloro_mito

#wget "https://sourceforge.net/projects/mira-assembler/files/MIRA/development/mira_4.9.6_linux-gnu_x86_64_static.tar.bz2/download"
#tar -xvjf download

chloro_mito=/path/to/USER_ROOT/08_YUCFL_popgene/04_TE/00_readsfilter/chloro_mito.fasta

/path/to/USER_ROOT/08_YUCFL_popgene/04_TE/00_readsfilter/mira_V5rc1_linux-gnu_x86_64_static/bin/mirabait \
-I \
-o 02_chloro_mito \
-N $name \
-b $chloro_mito \
-p 00_cleanread/${name}_clean_1.fastq 00_cleanread/${name}_clean_2.fastq \
-t $thr

mkdir -p 03_nuclear

module load pigz/2.8-vt5ps6w

pigz -p $thr -c "${name}_miss_${name}_clean_1.fastq" > "03_nuclear/${name}_clean_R1.fq.gz"
pigz -p $thr -c "${name}_miss_${name}_clean_2.fastq" > "03_nuclear/${name}_clean_R2.fq.gz"

rm ${name}_miss_${name}_clean_*.fastq