#!/usr/bin/env bash
# Edit these paths if your Nova project has moved.
PROJECT=${PROJECT:-/path/to/CGK_PROJECT/04_bam2fasta}
GENETREES="$PROJECT/03_genetrees"
ORIGINAL="$GENETREES/phyparts/MCMCtree"
ALIGNMENT="$ORIGINAL/mcmctree_concat.phy"
TOPOLOGY="$GENETREES/phyparts/n18784_filter_trees_bs03_rt_astral_rt.tre"
OUTGROUPS="$GENETREES/outgroup.list"
IQTREE_SIF="$ORIGINAL/iqtree3.sif"
MCMCTREE="$ORIGINAL/paml/src/mcmctree"
# All three steps use this new folder. Change RUN before step1 for another run.
RUN=${RUN:-$SCRIPT_DIR/run_5to10Ma_01}
THREADS=${SLURM_CPUS_PER_TASK:-6}
# One time unit = 100 million years: 0.05 = 5 Ma; 0.10 = 10 Ma.
ROOT_MIN=0.05
ROOT_MAX=0.10
TIME_SCALE=100
BURNIN=20000
SAMPFREQ=100
NSAMPLE=20000
