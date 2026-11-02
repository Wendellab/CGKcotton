#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=400G 
#SBATCH --time=1-05:00:00
#SBATCH --mail-type=ALL
#SBATCH --open-mode=append
#SBATCH --output="job.vcf_n319.%J.out"
#SBATCH --job-name="jointGeno_n319"

module load py-ete3
module load openjdk/17.0.5_8-5pdrwz2

cp ../n18805_filter_trees_bs03_rt.tre n18784_filter_trees_bs03_rt.tre
cp ../n18805_filter_trees_bs03_rt_astral.tre  n18784_filter_trees_bs03_rt_astral.tre

sed -i 's/[[:space:]]\+$//' n18784_filter_trees_bs03_rt_astral.tre


python ../reroot_trees2.py  n18784_filter_trees_bs03_rt_astral.tre ../outgroup.list >  n18784_filter_trees_bs03_rt_astral_rt.tre


# manually deleted the space in the astral tree

java -jar -Xmx400g phyparts-0.0.1-SNAPSHOT-jar-with-dependencies.jar -a 1 -v -d n18784_filter_trees_bs03_rt.tre -m n18784_filter_trees_bs03_rt_astral_rt.tre  -o DCGK_n18784

python phypartspiecharts.py n18784_filter_trees_bs03_rt_astral_rt.tre DCGK_n18784 18784 --to_csv
