### 1. Find the single copy genes across CGK-D genomes

#### 1.1 Download D-CGK reference genomes from cottongene, remove the 'unplaced' contigs and rename and keep only the chromosome assmebly, and index each reference genome.
```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G 
#SBATCH --time=10:00:00
#SBATCH --mail-user=weixuan@iastate.edu
#SBATCH --mail-type=ALL
#SBATCH --open-mode=append
#SBATCH --output="job.refCGK.%J.out"
#SBATCH --job-name="jointrefCGK"


#G1_HAU reference genome
wget 'https://www.cottongen.org/cottongen_downloads/Gossypium_bickii/G1_HAU/assembly/G1.genome.fa.gz'

#C1_HAU reference genome
wget 'https://www.cottongen.org/cottongen_downloads/Gossypium_sturtianum/C1_HAU/assembly/C1.genome.fa.gz'

#G2_CRI reference genome
wget 'https://www.cottongen.org/cottongen_downloads/Gossypium_australe/G2_CRI_v1.1/assembly/GCA_005393395.2_CCRI_HENU_Gaus_1.1_genomic.fna.gz'

#K2_HAU reference genome
wget 'https://www.cottongen.org/cottongen_downloads/Gossypium_rotundifolium/HAU_G.rotundifolium_K2/assembly/Grotundifolium_genome_HAU_v1.0.fasta.gz'

#D5 reference genome 
wget "https://www.cottongen.org/cottongen_downloads/Gossypium_raimondii/PKU_G.raimondii_T2T/assembly/GWHBISS00000000.genome.fasta.gz"

gunzip *.gz
```
change all assmbely names to `Chr01` to `Chr13`
```
seqkit mutate -w0 C1.genome.fa | grep -A1 '>Chr' | cut -d ' ' -f1 > C1_HAUreference.fasta
seqkit mutate -w0 G1.genome.fa | grep -A1 '>Chr' | cut -d ' ' -f1 > G1_HAUreference.fasta

seqkit mutate -w0 GCA_005393395.2_CCRI_HENU_Gaus_1.1_genomic.fna | grep -A1 '>CM0' | \
awk '/^>CM0/ {
      match($0, /chromosome ([0-9]+)/, m);
      if (m[1] != "") {printf(">Chr%02d\n", m[1]); next}
  } {print}'  > G2_CRIreference.fasta

seqkit mutate -w0 Grotundifolium_genome_HAU_v1.0.fasta | grep -A1 '>Chr' | cut -d ' ' -f1 > K2_HAUreference.fasta

seqkit mutate -w0 GWHBISS00000000.genome.fasta | \
awk '/^>/ {
    match($0,/Chromosome ([0-9]+)/,a)
    printf(">Chr%02d\n",a[1])
    next
} {print}' > D5_T2T_PKUreference.fa
```
Index reference genomes
```
module load bwa/0.7.17-zgotlbn
module load  samtools/1.19.2-py311-qlmoxzv

for i in *.fasta
do
echo $i
bwa index $i
samtools faidx $i
done
```

#### 1.2 Scripts to show the divergence between reference genomes using mash/dotplot  
```
Ask Tony's help
```

#### 1.3 Download the annotation of D5 genome and rename the chromosome in GFF3 file to match with fasta file above  
```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200G 
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=weixuan@iastate.edu
#SBATCH --mail-type=ALL
#SBATCH --open-mode=append
#SBATCH --output="job.liftoff.%J.out"
#SBATCH --job-name="liftoff"

#https://github.com/agshumate/Liftoff

Dir=/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/

cd $Dir/04_liftoff_genespace/

module load liftoff/1.6.3.2-py311-iefauxh

awk 'BEGIN{
  for(i=1;i<=13;i++){
    old=sprintf("GWHBISS%08d",i);
    new=sprintf("Ch%02d",i);
    map[old]=new}}
{if($1 in map) $1=map[$1];
  print}' OFS="\t" D5_T2T_PKUreference.gff3 > D5_T2T_PKUreference_renamed.gff3
```
#### 1.4 Liftoff annotations from CGK using D5 annotation file
```
liftoff $Dir/C1_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o C1_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/G1_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o G1_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/G2_CRIreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o G2_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/K2_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o K2_liftoff -p 30 -polish -exclude_partial
```

Extract peptide sequences use gffread, but remove genes with introns largers than 200 `-i 200`, minimal length of transcript `-l 200` and merge extract transcripts `-M`; A side note, the `fa` peptide files can only contain partial of bed files. Fix the problematic site `.` to `X` in `gffread` output.
```
cd /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/04_liftoff_genespace

mkdir ../05_genespace/bed
mkdir ../05_genespace/peptide
mkdir ../05_genespace/strandbed

/lustre/hdd/LAS/jfw-lab/weixuan/00_BioinformaticTools/gffread/gffread D5_T2T_PKUreference_renamed.gff3  -M -g ../D5_T2T_PKUreference.fa -y ../05_genespace/peptide/D5_T2T_PKUreference.fa --keep-genes
/lustre/hdd/LAS/jfw-lab/weixuan/00_BioinformaticTools/gffread/gffread C1_liftoff_polished -M -g ../C1_HAUreference.fasta -y ../05_genespace/peptide/C1_HAUreference.fa --keep-genes
/lustre/hdd/LAS/jfw-lab/weixuan/00_BioinformaticTools/gffread/gffread G1_liftoff_polished  -M -g ../G1_HAUreference.fasta -y ../05_genespace/peptide/G1_HAUreference.fa --keep-genes
/lustre/hdd/LAS/jfw-lab/weixuan/00_BioinformaticTools/gffread/gffread G2_liftoff_polished  -M -g ../G2_CRIreference.fasta -y ../05_genespace/peptide/G2_CRIreference.fa --keep-genes
/lustre/hdd/LAS/jfw-lab/weixuan/00_BioinformaticTools/gffread/gffread K2_liftoff_polished -M -g ../K2_HAUreference.fasta -y ../05_genespace/peptide/K2_HAUreference.fa --keep-genes

cd ../05_genespace/peptide

sed -i '/^>/!s/\./X/g' C1_HAUreference.fa
sed -i '/^>/!s/\./X/g' G1_HAUreference.fa
sed -i '/^>/!s/\./X/g' D5_T2T_PKUreference.fa
sed -i '/^>/!s/\./X/g' G2_CRIreference.fa
sed -i '/^>/!s/\./X/g' K2_HAUreference.fa
```

#### 1.5 Convery gff3 into bed file, in here, however, we kept the strand information `+` or `-` for later `bam2consensus` fasta extraction
```
module load bedops/2.4.40-dt3y73e

# Input GFF3/GFF files
inputs=(
    C1_liftoff_polished
    G1_liftoff_polished
    G2_liftoff_polished
    K2_liftoff_polished
    D5_T2T_PKUreference_renamed.gff3
)

# Corresponding output BED names
outputs=(
    C1_HAUreference.bed
    G1_HAUreference.bed
    G2_CRIreference.bed
    K2_HAUreference.bed
    D5_T2T_PKUreference.bed
)

outdir="../05_genespace/strandbed"
mkdir -p "$outdir"

for i in "${!inputs[@]}"; do
    gff2bed < "${inputs[i]}" | awk -F'\t' '{
        if($8=="mRNA"){
            name=".";
            n = split($10,a,";")
            for(i=1;i<=n;i++) if(a[i] ~ /^ID=/){ split(a[i],b,"="); name=b[2] }
            print $1,$2,$3,name,".",$6
        }
    }' OFS='\t' > "$outdir/${outputs[i]}"
done

```

#### 1.6 Extracting gene names from peptide FASTA headers (lines starting with >), then filtering the strand BED so only genes present in the peptide set are kept.
```
bed_dir="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/05_genespace/strandbed"
peptide_dir="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/05_genespace/peptide"
out_dir="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/05_genespace/bed"

for bed in "$bed_dir"/*.bed; do
    fname=$(basename "$bed")
    pep_fa="$peptide_dir/${fname%.bed}.fa"

    awk 'NR==FNR{g[$0]; next} $4 in g {print $1"\t"$2"\t"$3"\t"$4}' \
      <(grep '>' "$pep_fa" | sed 's/>//') \
      "$bed" > "$out_dir/$fname"
done
```

#### 1.7 Run Genespace to find the single-copy orthologs
```
module load r
module load micromamba/1.4.2-7jjmfkf
eval "$(micromamba shell hook --shell=bash)"
micromamba activate /lustre/hdd/LAS/jfw-lab/weixuan/00_BioinformaticTools/envs/orthofinder_env

Rscript genesapce.R
```

### 2. Build gene trees using ortholog genes

#### 2.1 Find orthology genes that all contain same gene ID (gene name after `liftoff`) and run `bam2consensus` use `bambamtools`

```
grep ">" /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/05_genespace/orthofinder/Results_Sep07/Single_Copy_Orthologue_Sequences/*.fa | \
uniq -c |  awk '$1==5 {print $2}' | cut -d ">" -f2 > /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/n19029.txt


module load bambam/1.3

# Define samples and grep patterns
declare -A samples=(
    ["C1_HAUreference_n19029"]="C1|C2"
    ["G1_HAUreference_n19029"]="G1|G3"
    ["G2_CRIreference_n19029"]="G2"
    ["K2_HAUreference_n19029"]="K[0-9]"
    ["D5_T2T_PKUreference_n19029"]="D5"
)

bamlist="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/bamlist.txt"
bed_dir="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/05_genespace/strandbed"
outdir_base="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta"
gene_list="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/n19029.txt"

# Process each sample
for sample in "${!samples[@]}"; do
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
```

#### 2.2 Concatenate all orthologs from different differemt genome folders together; Reorientation sequence using strand information, then align each gene using [mafft](https://mafft.cbrc.jp/alignment/server/index.html), and trim each alignment with flag `-gt 0.7` with [trimal](https://vicfero.github.io/trimal/), and output the gene trees with [IQTREE2](https://github.com/iqtree/iqtree2), and the statistical information of each trimmed alignment using [ASMS.py](https://github.com/marekborowiec/AMAS).

```
#!/bin/bash
#SBATCH --cpus-per-task=80
#SBATCH --mem=200G
#SBATCH --time=24:00:00
#SBATCH --mail-user=weixuan@iastate.edu
#SBATCH --mail-type=ALL
#SBATCH --output="joboutput/job.n19029.%A_%a.out"
#SBATCH --error="joboutput/job.n19029.%A_%a.err"
#SBATCH --array=1-1000%10

ROOT=/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq
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

```

#### 2.2 Collect all information from individual gene trees and build an Astral tree

```
cd /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/01_DCGK_n19029tree

for f in *.treefile; do
    # strip extension
    base=$(basename "$f" .treefile)
    # remove DCGK_ prefix and .t1 suffix
    name=${base#DCGK_}
    name=${name%.t1}
    # prepend to tree lines
    sed "s/^/tree ${name} = /" "$f"
done > /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/03_genetrees/n19028_all_trees.tre

cd /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/02_DCGK_alnstat
cat * | sort | uniq > /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/03_genetrees/n19028_all_trees_stat.txt


## build an Astral tree with all 19,028 gene trees (one trimmed alignment had no variable sites), but we need to remove loci infor from tree files. 

cd /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/03_genetrees/

cut -d ' ' -f4 n19028_all_trees.tre > astral_input.tre
module load openjdk/21.0.3_9-vngib7s
java -Xmx200G -jar Astral/astral.5.7.8.jar -i astral_input.tre -o n19028_all_astral.tre 2>out.log


## Filter out 8,828 loci based on their trimmed alignment quality below

No_of_taxa == 41 				# No missing taxa
Alignment_length >= 200			# trimmed alignment length 200 bp and above 
Undetermined_characters <= 100	# the gaps '-' < 100 across all 200 x 41 sites
Missing_percent <= 1			# the total '-' should be lesser than 1% of the total sites
No_variable_sites >= 100		# the total '-' should be lesser than 1% of the total sites

awk 'NR==1 || ($2 == 41 && $3 >= 200 && $5 <= 100 && $6 <= 1 && $7 >= 10 )' n19028_all_trees_stat.txt > n19028_all_trees_stat_filter.txt

tail -n +2 n19028_all_trees_stat_filter.txt | cut -f1 -d '.' | sed 's/DCGK_//g' > n8807list.txt

grep -Ff n8807list.txt n19028_all_trees.tre | cut -f4 -d " " > n8807_filter_trees.tre

java -Xmx200G -jar Astral/astral.5.7.8.jar -i n8807_filter_trees.tre -o n8807_all_astral.tre 2>out2.log

```

















