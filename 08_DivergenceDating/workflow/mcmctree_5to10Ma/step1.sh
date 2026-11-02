#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=1-05:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="step1.%J.out"
#SBATCH --job-name="CGK_prepare"

# Stop if a command fails, so later commands do not use incomplete files.
set -e
module load py-ete3

# Submit all scripts from this folder on Nova.
cd /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/mcmctree_5to10Ma

# Make a NEW results folder. mkdir stops if it already exists.
mkdir run_5to10Ma_01
mkdir run_5to10Ma_01/step1

# Use the existing ASTRAL topology and root it between D5 and CGK.
# 1 time unit = 100 Ma: 0.05 = 5 Ma and 0.10 = 10 Ma.
# This is the D-CGK root, NOT the first split within CGK.
python3 prepare_trees.py calibrate \
 --tree ../../n18784_filter_trees_bs03_rt_astral_rt.tre \
 --outgroups ../../../outgroup.list \
 --lower 0.05 --upper 0.10 \
 --output run_5to10Ma_01/step1/species.calibrated.nwk > run_5to10Ma_01/step1/prepare.log 2>&1

# Record where the unchanged DNA alignment will come from.
ls -lh ../mcmctree_concat.phy
cp step1.sh step2.sh step3.sh run_5to10Ma_01/step1/
touch run_5to10Ma_01/step1/step1.done
