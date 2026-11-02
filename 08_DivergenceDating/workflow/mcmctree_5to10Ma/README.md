# MCMCtree: 5–10 Ma calibration, outputs grouped by step

On Nova, submit from this folder:

    sbatch step1.sh

Wait for success, then submit step2.sh. Wait for success, then submit step3.sh.
Do not submit all three at once without job dependencies.
All scripts contain explicit Nova paths and simple sequential commands.

## Output folders

    run_5to10Ma_01/
      step1/
        species.calibrated.nwk
        prepare.log
        step1.sh, step2.sh, step3.sh  (copies for the run record)
        step1.done
      step2/
        DCGK.rooted.nwk
        DCGK.dummy.phy
        DCGK.mcmctree.hessian
        DCGK.mcmctree.ctl
        iqtree.console.log
        other IQ-TREE logs/reports/checkpoints
        step2.done
      step3/
        prior/
        chain1/
        chain2/
        step3.done

Each prior/chain folder contains run.ctl, matching IQ-TREE inputs, console.log,
mcmc.log, mcmctree.out, mcmctree.ckp, FigTree.tre, plot.log,
FigTree_HPD.pdf, FigTree_HPD.png and FigTree_HPD_nodes.csv.
PAML may produce additional auxiliary files.

SLURM job logs (step1.JOBID.out, step2.JOBID.out, step3.JOBID.out) stay in the
submission folder: SLURM opens them before the scripts create result folders.

## What each step does

1. Root the existing ASTRAL topology between D5 and CGK, remove old branch
   lengths/support, and annotate the root with B(0.05,0.10).
2. Reuse the historical concatenated alignment and fixed topology to generate
   a new IQ-TREE likelihood bundle with GTR+G4 and independent branch rates.
3. Run a prior-only analysis and two independent posterior chains sequentially,
   then draw a separate dated tree with blue 95% HPD bars for each run.

One time unit = 100 Ma. The calibration describes the D–CGK root, not the crown
of CGK alone. This is an assumed secondary-calibration scenario requiring a
scientific justification; the soft bounds do not strictly exclude outside ages.
The plotting command multiplies both ages and HPD endpoints by 100 to show Ma.
The node CSV includes plotting node IDs, ages, HPD limits and descendant tips;
plotting IDs are not PAML parameter IDs.

## Inputs and software

Paths are explicit in the scripts. The existing topology is
phyparts/n18784_filter_trees_bs03_rt_astral_rt.tre; outgroups are in
03_genetrees/outgroup.list; the alignment is MCMCtree/mcmctree_concat.phy.
The historical alignment has 18,785 loci, 40 samples and 46,607,679 sites;
topology inference used 18,784 loci. The extra alignment locus is GR02G1988.
This rerun preserves that historical difference and uses one alignment partition.

Step1 uses module py-ete3; step2 uses apptainer and the existing iqtree3.sif;
step3 uses py-ete3, an R module, and the existing IQ-TREE-compatible PAML binary.
Check the R module name on Nova. Resource requests are initial estimates.
Python/R helpers are included. settings.sh is retained for reference but is
not read by these simplified scripts.

## Chain length and result checks

The scripts currently retain 20,000 burn-in iterations, sampling every 100
iterations, saving 20,000 samples: 2,020,000 total iterations per chain.
To use the longer setting discussed, change step2 to
--mcmc-iter 100000,100,50000 and all three commands in step3 to
--burnin 100000 --sampfreq 100 --nsample 50000.

Inspect chain1/mcmc.log and chain2/mcmc.log in Tracer for stationary traces,
adequate ESS and agreement. Compare prior/posterior ages. Do not combine chains
or report dates until diagnostics support doing so. No convergence is guaranteed
by a fixed iteration count, and no combined-chain plot is generated automatically.

## Existing or failed runs

These updated scripts expect the new step1/step2/step3 layout. They do not move
existing results or resume checkpoints. mkdir refuses existing stage folders.
If run_5to10Ma_01 already exists, choose a new name consistently in all three
scripts for a fresh run. Original inputs and previous analyses are preserved.
Earlier script versions are saved in before_step_output_folders/ and previous_99_Supplemental/scripts/.

No Nova jobs have been submitted by this update. Bash syntax execution remains
unavailable on this Windows host; validate on Nova before submission:

    bash -n step1.sh
    bash -n step2.sh
    bash -n step3.sh

## One long posterior chain

Submit from the pipeline folder:

    bash -n step3_long.sh
    sbatch step3_long.sh

Uses existing step2 likelihood files and the corrected make_control.py helper.
Does not rerun steps1/2, the prior, or either old posterior chain.
Output: run_5to10Ma_01/step3/chain_long_01/.
New seed: 86421. Burn-in: 1,000,000; sample interval: 500;
saved samples: 100,000; total iterations: 51,000,000.
The job requests 1 CPU, 8 GB and 48 hours. Based on the earlier approximately
28-minute run for 2.02 million iterations, a rough runtime is 12 hours, but
actual runtime depends on the node and sampling behavior.
All original model/calibration settings are retained. This starts fresh.
Check mcmc.log in Tracer for trace stability and adequate ESS; increasing
sampling interval alone does not cure poor mixing. Previous shorter chains
remain available for comparison. A single longer chain is not proof of convergence.
