module load bedtools2/2.31.1-py311-6kemgt3

bed=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/bed/G2_CRIreference.bed
ref=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/G2_CRIreference.fasta

grep -Ff n18784_gene_list.csv $bed > G2_CRIreference_n18784.bed

bedtools getfasta -fi $ref -bed G2_CRIreference_n18784.bed -fo G2_CRI_generef_n18784.fasta

bedtools getfasta -fi $ref -bed $bed -fo G2_CRI_generef_n43848.fasta


bedtools getfasta \
    -fi "$ref" \
    -bed G2_CRIreference_n18784.bed \
    -name \
    -fo G2_CRI_generef_n18784.fasta
	
#########################################################################

module load bwa samtools

bwa index G2_CRI_generef_n18784.fasta
samtools faidx G2_CRI_generef_n18784.fasta

bwa index G2_CRI_generef_n43848.fasta
samtools faidx G2_CRI_generef_n43848.fasta