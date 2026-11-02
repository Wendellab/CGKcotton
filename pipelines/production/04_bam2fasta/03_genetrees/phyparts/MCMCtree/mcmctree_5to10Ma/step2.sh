#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=128G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="step2.%J.out"
#SBATCH --job-name="CGK_likelihood"

# Stop if a command fails, so later commands do not use incomplete files.
set -e
module purge
module load apptainer
apptainer --version

cd /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/mcmctree_5to10Ma

# First confirm step1 finished. Keep all new IQ-TREE files together.
test -f run_5to10Ma_01/step1/step1.done
mkdir run_5to10Ma_01/step2
cd run_5to10Ma_01/step2

# Reuse the historical DNA alignment and the newly calibrated topology.
# -te fixes the relationships; GTR+G4 models sequence change.
# This estimates a NEW Hessian rather than reusing the old 5-8 Ma bundle.
apptainer exec --bind /path/to/CGK_PROJECT/04_bam2fasta /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/iqtree3.sif iqtree3 \
 -s ../../../mcmctree_concat.phy \
 -m GTR+G4 \
 -te ../step1/species.calibrated.nwk \
 --dating mcmctree \
 --mcmc-clock IND \
 --mcmc-iter 20000,100,20000 \
 -T 6 --seed 784168 --prefix DCGK > iqtree.console.log 2>&1

# Check the four files needed by step3.
test -s DCGK.rooted.nwk
test -s DCGK.dummy.phy
test -s DCGK.mcmctree.hessian
test -s DCGK.mcmctree.ctl
# Never edit/reorder the generated tree: it must match its Hessian.
touch step2.done
