#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --output="step3_retry.%J.out"
#SBATCH --job-name="CGK_retry"
set -e

# Only base Python and R are needed here; ETE3 is not used by this step.
module purge
module load r
command -v python3
command -v Rscript
cd /path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/mcmctree_5to10Ma

test -f run_5to10Ma_01/step2/step2.done
cd run_5to10Ma_01/step3

# Keep the completed prior and failed chain files unchanged.
# NEW posterior folders: this script refuses to overwrite an earlier retry.
mkdir chain1_retry chain2_retry
python3 ../../make_control.py ../step2/DCGK.mcmctree.ctl chain1_retry/run.ctl \
 --seed 24681 --usedata 2 --burnin 20000 --sampfreq 100 --nsample 20000
python3 ../../make_control.py ../step2/DCGK.mcmctree.ctl chain2_retry/run.ctl \
 --seed 97531 --usedata 2 --burnin 20000 --sampfreq 100 --nsample 20000

cd chain1_retry
/path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/paml/src/mcmctree run.ctl > console.log 2>&1
Rscript ../../../plot_FigTree_HPD.R FigTree.tre 100 'Age before present (Ma)' > plot.log 2>&1

cd ../chain2_retry
/path/to/CGK_PROJECT/04_bam2fasta/03_genetrees/phyparts/MCMCtree/paml/src/mcmctree run.ctl > console.log 2>&1
Rscript ../../../plot_FigTree_HPD.R FigTree.tre 100 'Age before present (Ma)' > plot.log 2>&1

touch ../step3_retry.done
# Compare chain1_retry and chain2_retry in Tracer before reporting dates.
