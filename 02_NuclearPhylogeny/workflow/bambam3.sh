#!/bin/bash
#SBATCH --cpus-per-task=80
#SBATCH --mem=200G
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="joboutput/job.n19029.%A_%a.out"
#SBATCH --error="joboutput/job.n19029.%A_%a.err"
#SBATCH --array=1-1000%10

ROOT=/path/to/CGK_PROJECT
# File with gene names
gene_file=$ROOT/04_bam2fasta/n19029.txt

# Create output directories if they do not exist
mkdir -p joboutput
mkdir -p $ROOT/04_bam2fasta/00_DCGK_n19029
mkdir -p $ROOT/04_bam2fasta/01_DCGK_n19029tree
mkdir -p $ROOT/04_bam2fasta/02_DCGK_alnstat
# Load modules
module load mafft/7.505-3bx4zsi
module load iqtree2/2.2.2.7-py310-kcqit6n
module load seqtk/1.3-tstesdq
module load parallel/20240822-cvsr3ld

run () {
    gene=$1

    # Get the gene name for this array task
    echo "Processing gene: $gene"

    # Build concatenated FASTA
    for ref in C1_HAU D5_T2T_PKU G1_HAU G2_CRI K2_HAU; do
        dir=$(grep -e "$gene" \
                    $ROOT/04_bam2fasta/${ref}reference_n19029/${ref}reference_n19029.bed |
                 cut -f 6)
        rc=""
        if [ "$dir" = '-' ]; then rc="-r"; fi

        seqtk seq $rc $ROOT/04_bam2fasta/${ref}reference_n19029/$gene.fasta
    done |
 sed "s|$ROOT/03_gvcfs_vcf/realignBam/||g" |
 sed "s|$ROOT/03_gvcfs_vcf/G2realignBam/||g" |
 sed 's/.realign.bam//g' | 
 sed '/^>/!s/N/-/g' \
     > /dev/shm/$gene.fa

cd $ROOT/04_bam2fasta/00_DCGK_n19029/

# MAFFT alignment
mafft --thread $SLURM_CPUS_PER_TASK /dev/shm/$gene.fa \
    > DCGK_${gene}_aln.fasta
rm /dev/shm/$gene.fa
# Gap trimming with trimAl
$ROOT/../00_BioinformaticTools/trimal/source/trimal \
    -in DCGK_${gene}_aln.fasta \
    -out DCGK_${gene}_aln_trim.fasta \
    -gt 0.7

# IQ-TREE phylogeny
iqtree2 -s DCGK_${gene}_aln_trim.fasta -B 1000 -T AUTO \
    --prefix /tmp/DCGK_${gene}
	
#rm $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.*log
#rm $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.*iqtree
#rm $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.*bionj
#rm $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.*phy
#rm $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.*nex
#rm $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.*contree
#rm $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.*gz
#rm $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.*.mldist

mv  /tmp/DCGK_${gene}*.treefile $ROOT/04_bam2fasta/01_DCGK_n19029tree/
rm -f /tmp/DCGK_${gene}.*

#sed -i "1s/^/tree ${gene} = /" $ROOT/04_bam2fasta/01_DCGK_n19029tree/DCGK_${gene}.treefile

echo "Processing gene: $gene"
python $ROOT/04_bam2fasta/AMAS.py summary -d dna -f fasta -i $ROOT/04_bam2fasta/00_DCGK_n19029/DCGK_${gene}_aln_trim.fasta -o $ROOT/04_bam2fasta/02_DCGK_alnstat/DCGK_${gene}

}

export ROOT
export -f run

split -n "l/${SLURM_ARRAY_TASK_ID}/1000" $gene_file |
    parallel run
	


#for f in *.treefile; do
    # strip extension
#    base=$(basename "$f" .treefile)
    # remove DCGK_ prefix and .t1 suffix
#    name=${base#DCGK_}
#    name=${name%.t1}
    # prepend to tree lines
#    sed "s/^/tree ${name} = /" "$f"
#done > ../n19028_all_trees.tre
