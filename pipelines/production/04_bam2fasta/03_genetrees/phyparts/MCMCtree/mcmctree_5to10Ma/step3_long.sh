#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="step3_long.%J.out"
#SBATCH --job-name="CGK_long"
set -e

# One long posterior chain; use the existing successful step2 files.
# No new prior analysis and no second posterior chain are run here.
module purge
module load r
command -v python3
command -v Rscript

cd /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/mcmctree_5to10Ma

test -f run_5to10Ma_01/step2/step2.done
cd run_5to10Ma_01/step3

# NEW folder: old chains are preserved. mkdir stops if this already exists.
mkdir chain_long_01

# Discard 1,000,000 initial iterations.
# Then save 100,000 samples, one every 500 iterations.
# Total = 1,000,000 + (500 x 100,000) = 51,000,000 iterations.
# Keep the existing independent-rates model, priors and 5-10 Ma calibration.
python3 ../../make_control.py ../step2/DCGK.mcmctree.ctl chain_long_01/run.ctl \
 --seed 86421 --usedata 2 \
 --burnin 1000000 --sampfreq 500 --nsample 100000

cp ../../step3_long.sh chain_long_01/submitted_script.sh
cd chain_long_01

# Start a NEW chain; this is not a checkpoint continuation.
/path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/paml/src/mcmctree run.ctl > console.log 2>&1

test -s mcmc.log
test -s FigTree.tre

# Plot node ages and their 95% HPD intervals in millions of years.
Rscript ../../../plot_FigTree_HPD.R FigTree.tre 100 'Age before present (Ma)' > plot.log 2>&1

touch long_chain.done
# Check traces and ESS in Tracer before using dates in the paper.
# A long run does not guarantee good mixing or convergence.
