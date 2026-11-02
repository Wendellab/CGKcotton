#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200G 
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --open-mode=append
#SBATCH --output="job.liftoff.%J.out"
#SBATCH --job-name="liftoff"

#https://github.com/agshumate/Liftoff

Dir=/path/to/CGK_PROJECT/00_ref_GCF_0256985451/

cd $Dir/04_liftoff_genespace/

module load liftoff/1.6.3.2-py311-iefauxh

#awk 'BEGIN{
#  for(i=1;i<=13;i++){
#    old=sprintf("GWHBISS%08d",i);
#    new=sprintf("Ch%02d",i);
#    map[old]=new
#  }
#}
#{
#  if($1 in map) $1=map[$1];
#  print
#}' OFS="\t" D5_T2T_PKUreference.gff3 > D5_T2T_PKUreference_renamed.gff3


liftoff $Dir/C1_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o C1_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/G1_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o G1_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/G2_CRIreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o G2_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/K2_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o K2_liftoff -p 30 -polish -exclude_partial

cd /path/to/CGK_PROJECT/00_ref_GCF_0256985451/04_liftoff_genespace

module load bedops/2.4.40-dt3y73e

gff2bed < C1_liftoff_polished | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name
    }
}' OFS='\t' > ../05_genespace/C1_HAUreference.bed

gff2bed < G1_liftoff_polished | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name
    }
}' OFS='\t' > ../05_genespace/G1_HAUreference.bed

gff2bed < G2_liftoff_polished | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name
    }
}' OFS='\t' > ../05_genespace/G2_CRIreference.bed

gff2bed < K2_liftoff_polished | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name
    }
}' OFS='\t' > ../05_genespace/K2_HAUreference.bed

gff2bed < D5_T2T_PKUreference_renamed.gff3 | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name
    }
}' OFS='\t' > ../05_genespace/D5_T2T_PKUreference.bed


/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread D5_T2T_PKUreference_renamed.gff3 -g ../D5_T2T_PKUreference.fa -y ../05_genespace/D5_T2T_PKUreference.fa --keep-genes
/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread C1_liftoff_polished -g ../C1_HAUreference.fasta -y ../05_genespace/C1_HAUreference.fa --keep-genes
/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread G1_liftoff_polished -g ../G1_HAUreference.fasta -y ../05_genespace/G1_HAUreference.fa --keep-genes
/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread G2_liftoff_polished -g ../G2_CRIreference.fasta -y ../05_genespace/G2_CRIreference.fa --keep-genes
/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread K2_liftoff_polished -g ../K2_HAUreference.fasta -y ../05_genespace/K2_HAUreference.fa --keep-genes

cd ../05_genespace/

sed -i '/^>/!s/\./X/g' C1_HAUreference.fa
sed -i '/^>/!s/\./X/g' G1_HAUreference.fa
sed -i '/^>/!s/\./X/g' D5_T2T_PKUreference.fa
sed -i '/^>/!s/\./X/g' G2_CRIreference.fa
sed -i '/^>/!s/\./X/g' K2_HAUreference.fa



mkdir split_gff

awk '$1 ~ /^#/ {print > "split_gff/header.gff3"; next} 
     {print > "split_gff/"$1".gff3"}' K2_liftoff_polished

for f in split_gff/Ch*.gff3; do
    cat split_gff/header.gff3 $f > $f.tmp && mv $f.tmp $f
done

mkdir per_chr_output

for chr_gff in split_gff/Ch*.gff3; do
    chr=$(basename $chr_gff .gff3)
    /path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread \
        $chr_gff \
        -g ../K2_HAUreference.fasta \
        -y per_chr_output/${chr}.fa \
        --keep-genes
done


module load openjdk/21.0.3_9-vngib7s
git clone https://github.com/wyp1125/MCScanX.git
cd MCScanX/
make
/path/to/USER_ROOT/00_BioinformaticTools/MCScanX


module purge


module load python/3.8.18-4j5jvxi
module load py-numpy/1.24.4-py311-eihztow
module load orthofinder/2.5.5-py310-azfukyj
module load diamond/2.0.15-4c4o2ux

#module load genespace/1.2.3
module load r
module load micromamba/1.4.2-7jjmfkf

eval "$(micromamba shell hook --shell=bash)"
micromamba activate /path/to/USER_ROOT/00_BioinformaticTools/envs/orthofinder_env


R
#devtools::install_github("jtlovell/GENESPACE", lib = "/path/to/USER_ROOT/00_BioinformaticTools/rpackage")
#BiocManager::install(c("Biostrings", "rtracklayer"), lib = "/path/to/USER_ROOT/00_BioinformaticTools/rpackage")

library(GENESPACE, lib.loc = "/path/to/USER_ROOT/00_BioinformaticTools/rpackage")

gpar <- init_genespace(
  wd = "/path/to/CGK_PROJECT/00_ref_GCF_0256985451/05_genespace", 
  path2mcscanx = "/path/to/USER_ROOT/00_BioinformaticTools/MCScanX")
  
gpar <- run_genespace(gsParam = gpar, overwrite = T) 


