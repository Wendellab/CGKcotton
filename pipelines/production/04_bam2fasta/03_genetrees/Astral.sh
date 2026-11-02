#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=200G 
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="job.Astral.%J.out"
#SBATCH --job-name="Astral"


cd /path/to/CGK_PROJECT/04_bam2fasta/01_DCGK_n19029tree

for f in *.treefile; do
    # strip extension
    base=$(basename "$f" .treefile)
    # remove DCGK_ prefix and .t1 suffix
    name=${base#DCGK_}
    name=${name%.t1}
    # prepend to tree lines
    sed "s/^/tree ${name} = /" "$f"
done > /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/n19028_all_trees.tre

cd /path/to/CGK_PROJECT/04_bam2fasta/02_DCGK_alnstat
cat * | sort | uniq > /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/n19028_all_trees_stat.txt



awk 'NR==1 || ($2 == 40 )' n19028_all_trees_stat.txt > n19028_all_trees_stat_filter.txt
tail -n +2 n19028_all_trees_stat_filter.txt | cut -f1 -d '.' | sed 's/DCGK_//g'  > n18805list.txt
grep -Ff n18805list.txt n19028_all_trees.tre | cut -f4 -d " " > n18805_filter_trees.tre


################################################################

# Load micromamba module and init shell
module load micromamba/1.4.2-7jjmfkf
eval "$(micromamba shell hook --shell=bash)"

# Create environment with newick_utils
#micromamba create --root-prefix /path/to/USER_ROOT/00_BioinformaticTools/ \
#  -n newick_env \
#  newick_utils \
#  -c conda-forge -c bioconda

# Activate it with absolute path
micromamba activate /path/to/USER_ROOT/00_BioinformaticTools/envs/newick_env

nw_ed ./n18805_filter_trees.tre 'i & b<=30' o > n18805_filter_trees_bs03.tre

micromamba deactivate



 
module load py-ete3/3.1.2-py310-46bvzjd
  
python reroot_trees2.py n18805_filter_trees_bs03.tre outgroup.list > n18805_filter_trees_bs03_rt.tre

module load openjdk/21.0.3_9-vngib7s
java -Xmx200G -jar ../old_03_genetrees/Astral/astral.5.7.8.jar -i n18805_filter_trees_bs03_rt.tre -o n18805_filter_trees_bs03_rt_astral.tre 2>out.log


#########################################

sed -f <(sed 's/$/d/' skipped_trees.txt) n18805list.txt | sed 's/$/SAMPLE_002/' >../D5_T2T_PKUreference_n19029/outgroup/genelist_n40_outgroup.txt

for f in *.fasta; do
    prefix=$(basename "$f" .fasta)
	seqkit mutate -w0 "$f"| sed "s/^>/>${prefix}_/" >> outgroup/all_renamed.fasta
done

sed -i -e 's|\.t1_/path/to/CGK_PROJECT/03_gvcfs_vcf/realignBam/||g' \
       -e 's|\.realign.bam||g'  all_renamed.fasta

seqkit grep -f genelist_n40_outgroup.txt all_renamed.fasta -o /path/to/CGK_PROJECT/05_genevcf/ref_D5n18785.fasta



########################################

cat skipped_trees.txt  | tr "\n" "|"

nl n18805_filter_trees_bs03.tre  | grep -w -E "796|1913|1950|2024|2477|4053|4271|6108|11713|12395|12807|14999|15150|15297|15411|15460|15778|16188|17100|17322" | cut -f2 > test.tre
