#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="step3.%J.out"
#SBATCH --job-name="CGK_MCMC"

# Stop if a command fails, so later commands do not use incomplete files.
set -e
module load py-ete3
# Change this module name if Nova uses a different name for R.
module load r

cd /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/mcmctree_5to10Ma

test -f run_5to10Ma_01/step2/step2.done
command -v Rscript
mkdir run_5to10Ma_01/step3
cd run_5to10Ma_01/step3

# Separate folders prevent chains from overwriting each other's files.
mkdir prior chain1 chain2

# PRIOR: ages allowed by the calibration and other priors, without DNA likelihood.
python3 ../../make_control.py ../step2/DCGK.mcmctree.ctl prior/run.ctl \
 --seed 13579 --usedata 0 --burnin 20000 --sampfreq 100 --nsample 20000

# CHAIN 1: first posterior analysis, using DNA and priors.
python3 ../../make_control.py ../step2/DCGK.mcmctree.ctl chain1/run.ctl \
 --seed 24681 --usedata 2 --burnin 20000 --sampfreq 100 --nsample 20000

# CHAIN 2: same model, different random seed, to check agreement.
python3 ../../make_control.py ../step2/DCGK.mcmctree.ctl chain2/run.ctl \
 --seed 97531 --usedata 2 --burnin 20000 --sampfreq 100 --nsample 20000

# Run the prior and draw its tree. 100 converts time units to Ma.
cd prior
/path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/paml/src/mcmctree run.ctl > console.log 2>&1
Rscript ../../../plot_FigTree_HPD.R FigTree.tre 100 'Age before present (Ma)' > plot.log 2>&1

# Run and plot posterior chain 1.
cd ../chain1
/path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/paml/src/mcmctree run.ctl > console.log 2>&1
Rscript ../../../plot_FigTree_HPD.R FigTree.tre 100 'Age before present (Ma)' > plot.log 2>&1

# Run and plot posterior chain 2.
cd ../chain2
/path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/paml/src/mcmctree run.ctl > console.log 2>&1
Rscript ../../../plot_FigTree_HPD.R FigTree.tre 100 'Age before present (Ma)' > plot.log 2>&1

touch ../step3.done
# NEXT: open both posterior mcmc.log files in Tracer; inspect traces and ESS.
# Compare the chains and compare prior/posterior before reporting ages.
