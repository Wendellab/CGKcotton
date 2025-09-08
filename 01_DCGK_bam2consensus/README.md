#### 1.1 Scripts to show the divergence between reference genomes using mash/dotplot 
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
    printf(">Ch%02d\n",a[1])
    next
} {print}' > D5_T2T_PKUreference.fa


module load bwa/0.7.17-zgotlbn
module load  samtools/1.19.2-py311-qlmoxzv

for i in *.fasta
do
echo $i
bwa index $i
samtools faidx $i
done
```

#### 1.1 Scripts to show the divergence between reference genomes using mash/dotplot 
```
