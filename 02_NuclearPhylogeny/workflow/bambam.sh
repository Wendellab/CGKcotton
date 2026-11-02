#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=15
#SBATCH --mem=200G 
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="job.bambam.%J.out"
#SBATCH --job-name="jointbambam"


#grep ">" /path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/orthofinder/Results_Aug29/Single_Copy_Orthologue_Sequences/*.fa | \
#uniq -c |  awk '$1==5 {print $2}' | cut -d ">" -f2 > /path/to/CGK_PROJECT/04_bam2fasta/n19029.txt



#grep -Ff n19029.txt /path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/bed/C1_HAUreference.bed > C1_HAUreference_n19029.bed
#grep -Ff n19029.txt /path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/bed/G1_HAUreference.bed > G1_HAUreference_n19029.bed
#grep -Ff n19029.txt /path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/bed/G2_CRIreference.bed > G2_CRIreference_n19029.bed
#grep -Ff n19029.txt /path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/bed/K2_HAUreference.bed > K2_HAUreference_n19029.bed
#grep -Ff n19029.txt /path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/bed/D5_T2T_PKUreference.bed > D5_T2T_PKUreference_n19029.bed


module load bambam/1.3
bambam bam2consensus --help

#ls -1 /path/to/CGK_PROJECT/03_gvcfs_vcf/realignBam/*.bam > bamlist.txt
#ls -1 /path/to/CGK_PROJECT/03_gvcfs_vcf/G2realignBam/*.bam >> bamlist.txt

mkdir C1_HAUreference_n19029
mkdir G1_HAUreference_n19029
mkdir G2_CRIreference_n19029
mkdir K2_HAUreference_n19029
mkdir D5_T2T_PKUreference_n19029

cd /path/to/CGK_PROJECT/04_bam2fasta/C1_HAUreference_n19029
bambam bam2consensus -g /path/to/CGK_PROJECT/04_bam2fasta/C1_HAUreference_n19029.bed $(grep -E "C1|C2" /path/to/CGK_PROJECT/04_bam2fasta/bamlist.txt | tr '\n' '\t') 

cd /path/to/CGK_PROJECT/04_bam2fasta/G1_HAUreference_n19029
bambam bam2consensus -g /path/to/CGK_PROJECT/04_bam2fasta/G1_HAUreference_n19029.bed $(grep -E "G1|G3" /path/to/CGK_PROJECT/04_bam2fasta/bamlist.txt | tr '\n' '\t') 

cd /path/to/CGK_PROJECT/04_bam2fasta/G2_CRIreference_n19029
bambam bam2consensus -g /path/to/CGK_PROJECT/04_bam2fasta/G2_CRIreference_n19029.bed $(grep -E "G2" /path/to/CGK_PROJECT/04_bam2fasta/bamlist.txt | tr '\n' '\t') 

cd /path/to/CGK_PROJECT/04_bam2fasta/K2_HAUreference_n19029
bambam bam2consensus -g /path/to/CGK_PROJECT/04_bam2fasta/K2_HAUreference_n19029.bed $(grep -E "K[0-9]" /path/to/CGK_PROJECT/04_bam2fasta/bamlist.txt | tr '\n' '\t') 

cd /path/to/CGK_PROJECT/04_bam2fasta/D5_T2T_PKUreference_n19029
bambam bam2consensus -g /path/to/CGK_PROJECT/04_bam2fasta/D5_T2T_PKUreference_n19029.bed $(grep -E "D5" /path/to/CGK_PROJECT/04_bam2fasta/bamlist.txt | tr '\n' '\t') 


file=/path/to/CGK_PROJECT/04_bam2fasta/n19029.txt

gene=$(cat $file | sed -n ${SLURM_ARRAY_TASK_ID}p)
echo "Samplebam = " $gene


/path/to/CGK_PROJECT/03_gvcfs_vcf/G2realignBam/

cat C1_HAUreference_n19029/$gene.fasta \
    D5_T2T_PKUreference_n19029/$gene.fasta \
    G1_HAUreference_n19029/$gene.fasta \
    G2_CRIreference_n19029/$gene.fasta \
    K2_HAUreference_n19029/$gene.fasta \
| sed 's/\/lustre\/hdd\/LAS\/PROJECT_GROUP\/AUTHOR\/10_Australian_Reseq\/03_gvcfs_vcf\/realignBam\///g' \
| sed 's/\/lustre\/hdd\/LAS\/PROJECT_GROUP\/AUTHOR\/10_Australian_Reseq\/03_gvcfs_vcf\/G2realignBam\///g' \
| sed 's/.realign.bam//g' \
> 00_DCGK_n19029/DCGK_$gene.fasta

cd 00_DCGK_n19029/

# Multiple sequence alignment with MAFFT
mafft --thread 10 00_DCGK_n19029/DCGK_${gene}.fasta \
    > 00_DCGK_n19029/DCGK_${gene}_aln.fasta

# Gap trimming with trimAl (remove columns with >70% gaps)
 /path/to/USER_ROOT/00_BioinformaticTools/trimal/source/trimal \
    -in 00_DCGK_n19029/DCGK_${gene}_aln.fasta \
    -out 00_DCGK_n19029/DCGK_${gene}_aln_trim.fasta \
    -gt 0.7

module load iqtree2/2.2.2.7-py310-kcqit6n
iqtree2 -s DCGK_${gene}_aln_trim.fasta -B 1000 -T AUTO \
--prefix 01_DCGK_n19029/DCGK_${gene}