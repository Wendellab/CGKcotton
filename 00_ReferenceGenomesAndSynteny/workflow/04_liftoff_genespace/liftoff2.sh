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


liftoff $Dir/C1_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o C1_liftoff -u C1_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/G1_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o G1_liftoff -u G1_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/G2_CRIreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o G2_liftoff -u G2_liftoff -p 30 -polish -exclude_partial
liftoff $Dir/K2_HAUreference.fasta $Dir/D5_T2T_PKUreference.fa -g ./D5_T2T_PKUreference_renamed.gff3 -o K2_liftoff -u K2_liftoff -p 30 -polish -exclude_partial

cd /path/to/CGK_PROJECT/00_ref_GCF_0256985451/04_liftoff_genespace

module load bedops/2.4.40-dt3y73e

gff2bed < C1_liftoff_polished | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name, ".", $6
    }
}' OFS='\t' > ../05_genespace/C1_HAUreference.bed

gff2bed < G1_liftoff_polished | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name, ".", $6
    }
}' OFS='\t' > ../05_genespace/G1_HAUreference.bed

gff2bed < G2_liftoff_polished | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name, ".", $6
    }
}' OFS='\t' > ../05_genespace/G2_CRIreference.bed

gff2bed < K2_liftoff_polished | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name, ".", $6
    }
}' OFS='\t' > ../05_genespace/K2_HAUreference.bed

gff2bed < D5_T2T_PKUreference_renamed.gff3 | awk -F'\t' '{
    if($8=="mRNA"){
        name=".";
        n = split($10, a, ";")
        for(i=1; i<=n; i++) if(a[i] ~ /^ID=/) { split(a[i], b, "="); name=b[2] }
        print $1, $2, $3, name, ".", $6
    }
}' OFS='\t' > ../05_genespace/D5_T2T_PKUreference.bed

/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread D5_T2T_PKUreference_renamed.gff3 -g ../D5_T2T_PKUreference.fa -y ../05_genespace/D5_T2T_PKUreference.fa --keep-genes  -i 10 -l 20 -M
/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread C1_liftoff_polished -g ../C1_HAUreference.fasta -y ../05_genespace/C1_HAUreference.fa --keep-genes -i 10 -l 20 -M
/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread G1_liftoff_polished -g ../G1_HAUreference.fasta -y ../05_genespace/G1_HAUreference.fa --keep-genes -i 10 -l 20 -M
/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread G2_liftoff_polished -g ../G2_CRIreference.fasta -y ../05_genespace/G2_CRIreference.fa --keep-genes -i 10 -l 20 -M
/path/to/USER_ROOT/00_BioinformaticTools/gffread/gffread K2_liftoff_polished -g ../K2_HAUreference.fasta -y ../05_genespace/K2_HAUreference.fa --keep-genes -i 10 -l 20 -M
 
 
 -M/--merge : cluster the input transcripts into loci, discarding
      "redundant" transcripts (those with the same exact introns
      and fully contained or equal boundaries)
 -i   discard transcripts having an intron larger than <maxintron>
 -l   discard transcripts shorter than <minlen> bases

[AUTHOR@nova23-9 04_liftoff_genespace]$ for f in *_liftoff_polished D5_T2T_PKUreference_renamed.gff3
do
    echo -ne "$f\t"
    awk '$3=="gene"{n++} END{print n}' "$f"
done
C1_liftoff_polished     44451
G1_liftoff_polished     44273
G2_liftoff_polished     43872
K2_liftoff_polished     41672
D5_T2T_PKUreference_renamed.gff3        53167
