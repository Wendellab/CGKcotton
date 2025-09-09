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

outdir="../05_genespace/bed"
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

#### 2.1 Find orthology genes that all contain same gene ID (gene name after `liftoff`)

```
grep ">" /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/05_genespace/orthofinder/Results_Sep07/Single_Copy_Orthologue_Sequences/*.fa | \
uniq -c |  awk '$1==5 {print $2}' | cut -d ">" -f2 > /lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/n7824.txt


module load bambam/1.3

# Define samples and grep patterns
declare -A samples=(
    ["C1_HAUreference_n7824"]="C1|C2"
    ["G1_HAUreference_n7824"]="G1|G3"
    ["G2_CRIreference_n7824"]="G2"
    ["K2_HAUreference_n7824"]="K[0-9]"
    ["D5_T2T_PKUreference_n7824"]="D5"
)

bamlist="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/bamlist.txt"
bed_dir="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/05_genespace/strandbed"
outdir_base="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta"
gene_list="/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/04_bam2fasta/n7824.txt"

# Process each sample
for sample in "${!samples[@]}"; do
    mkdir -p "$outdir_base/$sample"
    
    # Original BED file
    bed_in="$bed_dir/${sample%%_n7824}.bed"
    
    # Filter BED using n7824.txt
    bed_filtered="$outdir_base/$sample/${sample}.bed"
    grep -Ff "$gene_list" "$bed_in" > "$bed_filtered"
    
    # Get BAMs for this sample
    bams=$(grep -E "${samples[$sample]}" "$bamlist" | tr '\n' '\t')
    
    # Run bambam consensus
    cd "$outdir_base/$sample"
    bambam bam2consensus -g "$bed_filtered" $bams
done


```

