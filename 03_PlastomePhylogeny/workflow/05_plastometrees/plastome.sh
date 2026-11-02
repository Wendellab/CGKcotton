seqkit sort -n /path/to/CGK_PROJECT/02_getorg/02_outputplastome/iqtree/change_all_aln_selected.fasta  > change_all_aln_selected_sort.fasta

cd /path/to/CGK_PROJECT/02_getorg/01_plastome_output
shopt -s globstar  ##globstar will let us match files recursively
files=( *Kew*/*.fasta )  ##Array containing matched files, mention where to search and what files here
for i in "${files[@]}"; do d="${i%/*}"; d_="${d##*/}";  f="${i##*/}"; cp "$i" /path/to/CGK_PROJECT/02_getorg/04_CGKplastome/"${d_}"_"$f"; done

cp /path/to/CGK_PROJECT/02_getorg/01_plastome_output/mapref_bam/*.fasta /path/to/CGK_PROJECT/02_getorg/04_CGKplastome/
cp /path/to/CGK_PROJECT/02_getorg/01_plastome_output/SAMPLE_003/mapref/*.fasta /path/to/CGK_PROJECT/02_getorg/04_CGKplastome/
cp /path/to/CGK_PROJECT/02_getorg/01_plastome_output/SAMPLE_004/mapref/*.fasta /path/to/CGK_PROJECT/02_getorg/04_CGKplastome/

mkdir Kewraw/

rm *scaffols*

for FILE in *.fasta;
do
 awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $FILE > changed_${FILE}
done

cat changed_* > changed_additional_n15.fasta

module load mafft
mafft --thread 10 changed_additional_n15.fasta > changed_additional_n15_aln.fasta

cat change_all_aln_selected_sort.fasta changed_additional_n15_aln_selected.fasta | seqkit sort -n > changed_n43.fasta

mafft --thread 10 changed_n43.fasta > changed_n43_aln.fasta

/path/to/USER_ROOT/00_BioinformaticTools/trimal/source/trimal -nogaps \
-in changed_n43_aln.fasta -out changed_n43_aln_nogap.fasta

module load iqtree2/2.2.2.7-py310-kcqit6n
iqtree2 -s changed_n43_aln_nogap.fasta -B 1000 -T AUTO --prefix changed_n43_aln_nogap

module load py-biopython/1.81-py310-wt5scj7
seqmagick convert --output-format nexus --alphabet dna changed_n43_aln_nogap.fasta changed_n43_aln_nogap.fasta.nex

 python reroot_trees.py changed_n43_aln_nogap.treefile outgrouplist.txt > reroot_changed_n43_aln_nogap.treefile


cp changed_n43_aln.fasta changed_n41_aln.fasta
#manually remove outgroups 
module load mafft
mafft --thread 10 changed_n41_aln.fasta > changed_n41_aln_aln.fasta

/path/to/USER_ROOT/00_BioinformaticTools/trimal/source/trimal -nogaps \
-in changed_n41_aln_aln.fasta -out changed_n41_aln_aln_nogap.fasta


module load py-biopython/1.81-py310-wt5scj7
seqmagick convert --output-format nexus --alphabet dna changed_n41_aln_aln_nogap.fasta changed_n41_aln_aln_nogap.fasta.nex


##############################################################

cp ../04_CGKplastome/changed_n43.fasta changed_n42.fasta

## remove the "-" alignment from fasta, and extract K1 to send to getseq for annotation

module load mafft
mafft --thread 10 changed_n42.fasta > changed_n42_aln.fasta


/path/to/USER_ROOT/00_BioinformaticTools/trimal/source/trimal -nogaps \
-in changed_n42_aln.fasta -out changed_n42_aln_nogap.fasta


module load iqtree2/2.2.2.7-py310-kcqit6n
iqtree2 -s changed_n42_aln_nogap.fasta -B 1000 -T AUTO --prefix changed_n42_aln_nogap


#################################################################
###################################################################

seqkit subseq -r 88251:113817 SAMPLE_005.fasta | \
seqkit replace -p '.*' -r 'IRB' > SAMPLE_006.fasta

cat SAMPLE_006.fasta changed_n42.fasta > changed_n42_IRB.fasta

module load mafft
mafft --thread 10 changed_n42_IRB.fasta > changed_n42_IRB_aln.fasta

seqkit mutate -d 90386:116042 changed_n42_IRB_aln.fasta > changed_n42_IRB_aln_noIRB.fasta

/path/to/USER_ROOT/00_BioinformaticTools/trimal/source/trimal -nogaps \
-in changed_n42_IRB_aln_noIRB.fasta -out changed_n42_IRB_aln_noIRB_nogap.fasta

module load iqtree2/2.2.2.7-py310-kcqit6n
iqtree2 -s changed_n42_IRB_aln_noIRB_nogap.fasta -B 1000 -T AUTO --prefix changed_n42_IRB_aln_noIRB_nogap


grep "D5" changed_n42_IRB_aln_noIRB.fasta | sed 's/>//g' > outgroup.list

module load  py-ete3/3.1.2-py310-46bvzjd
python reroot_trees.py changed_n42_IRB_aln_noIRB_nogap.treefile outgroup.list > changed_n42_IRB_aln_noIRB_nogap_rt.treefile

###############################################################

awk -F'\t' 'BEGIN{ir_start=88251; ir_end=113817} /^#/ {print; next} $3=="gene" && ($2 ~ /Chloe|blatN/) && !($4>=ir_start && $5<=ir_end)' SAMPLE_007.gff3 > SAMPLE_008.gff3

module load py-biopython/1.81-py311-bwb4itq

python cpdna_gene_extract.py \
  changed_n42_aln.fasta \
  SAMPLE_008.gff3 \
  SAMPLE_009 \
  outputgene
  
  
python AMAS.py concat \
    -i outputgene/*.fasta \
    -f fasta \
    -d dna \
    -u phylip \
    -t cpDNA_supermatrix.fasta \
    -p partitions.txt
	
/path/to/USER_ROOT/00_BioinformaticTools/trimal/source/trimal -nogaps \
-in  cpDNA_supermatrix.fasta -out  cpDNA_supermatrix_nogap.fasta


module load iqtree2/2.2.2.7-py310-kcqit6n
iqtree2 -s cpDNA_supermatrix_nogap.fasta -B 1000 -T AUTO --prefix cpDNA_supermatrix_nogap