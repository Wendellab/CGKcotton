#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=200G 
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="job.Astral.%J.out"
#SBATCH --job-name="Astral"

module load bambam/1.3

# Define samples and grep patterns
declare -A samples=(
    ["G2_CRIreference_n19029"]="G2"
)

bamlist="/path/to/CGK_PROJECT/04_bam2fasta/bamlist.txt"
bed_dir="/path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace/strandbed"
outdir_base="/path/to/CGK_PROJECT/04_bam2fasta"
gene_list="/path/to/CGK_PROJECT/04_bam2fasta/n19029.txt"

# Process each sample
for sample in "${!samples[@]}"; do
	echo $sample
    mkdir -p "$outdir_base/$sample"
    
    # Original BED file
    bed_in="$bed_dir/${sample%%_n19029}.bed"
    
    # Filter BED using n19029.txt
    bed_filtered="$outdir_base/$sample/${sample}.bed"
    grep -Ff "$gene_list" "$bed_in" > "$bed_filtered"
    
    # Get BAMs for this sample
    bams=$(grep -E "${samples[$sample]}" "$bamlist" | tr '\n' '\t')
    
    # Run bambam consensus
    cd "$outdir_base/$sample"
    bambam bam2consensus -g "$bed_filtered" $bams
done


#    ["C1_HAUreference_n19029"]="C1|C2"
#    ["G1_HAUreference_n19029"]="G1|G3"
#    ["G2_CRIreference_n19029"]="G2"
#    ["K2_HAUreference_n19029"]="K[0-9]"
#    ["D5_T2T_PKUreference_n19029"]="D5"