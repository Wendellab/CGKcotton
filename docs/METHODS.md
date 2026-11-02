# Methods and parameters

These notes map the manuscript to supplied code; they do not silently replace historical settings with manuscript prose. Production versions and alternatives remain in pipelines/production/ for author reconciliation.

## Reference preparation and orthology

References: C1_HAU (G. sturtianum), G1_HAU (G. bickii), G2_CRI (G. australe), K2_HAU (G. rotundifolium), and D5_T2T_PKU (G. raimondii). The existing nuclear README documents downloads, chromosome header normalization, Liftoff annotation transfer, peptide/BED extraction, and GENESPACE. Production reference preparation and transanno chain-generation commands are now included. Check chromosome names against annotations before running; historical files use both Ch and Chr prefixes.

The genic consensus route assigns G3 to G1_HAU, whereas the reference-specific SNP route assigns G3 with G2 to G2_CRI. This difference is retained and should be explained in the manuscript if intentional.

## Nuclear tree and discordance

The retained author list contains 18,784 loci. Adapted alignment summaries use that exact list rather than reconstructing exclusions from ambiguous substrings. Production code uses MAFFT, trimAl -gt 0.7, IQ-TREE with 1,000 ultrafast bootstraps, support collapse, outgroup rooting, ASTRAL, and PhyParts. Historical scripts contain intermediate 19,028/18,805-locus analyses; do not assume those names are final datasets. The legacy nw_ed expression collapses support <=30; manuscript wording saying <30 should be reconciled.

## Plastomes

The source includes GetOrganelle assembly, historical mapping-to-consensus notes, whole-plastome alignment/IR-removal commands, and cpdna_gene_extract.py. The extraction helper maps ungapped reference positions to alignment positions and merges overlapping gene intervals. The output is therefore merged gene regions, not necessarily independent protein-coding CDS partitions. Check against the stated gene count and annotation choices. The source includes manual sample-selection/IR-coordinate steps that need final documentation.

## SNPs and population structure

Production scripts cover reference-specific calls, per-chromosome variant/invariant handling, transanno liftvcf, normalization, merging, PLINK, and LEA. The final manuscript describes --max-missing 0.9, --mac 1, --minDP 5, PLINK --mac 2, and LD pruning 50 10 0.2. minDP is a per-genotype threshold, not a mean site-depth threshold. Historical merge scripts have inconsistent filenames and manual removal steps; they are preserved, not presented as a turnkey pipeline.

The structure plotting task uses the K=4 ancestry plotting data from the external saved session. The saved kvalue table contains one selected run for each K; it is not all ten replicates and does not independently establish K=4 as the numerical minimum. Production LEA.R explores K=1:10 with 10 repetitions.

## Twisst and SNaQ

The plotting script records published-in-draft topology percentages. These are not recalculated during ordinary plotting. The optional new Twisst wrapper supplies three explicit topologies for each four-group comparison and summarizes normalized locus weights. Its grouping/weighting should be checked against the historical command before replacing manuscript values.

SNaQ uses six groups, with K9 pooled in K, 15 quartet sets, hmax=0:3 and 30 searches each. The portable entry point follows the supplied combined workflow. Inference was not executed in this update. Group pooling prevents testing an individual K9 reticulation separately. Gamma is an inheritance probability, not a bootstrap probability.

## f3 and k-mers

The f3 task recomputes the admixture f3 statistic from the saved six-by-six-by-788 f2 block array. Block construction, SNP ascertainment, block lengths, and population assignments still require final documentation. Z < -3 is the original screening rule; no new multiple-testing correction is implied.

K-mer summaries calculate sample-group means, replacing means <1 with zero. For plotting, retain rows present in 2-5 of the six groups with summed thresholded mean abundance >=10. The full count summaries are computed before these plotting filters. Exclusive pair counts require absence from all other groups; inclusive triple counts permit presence elsewhere. Number_of_kmers is summed under the assumption that intersections are disjoint distinct-k-mer sets. Copy abundance is not a count of introgressed segments or evidence of direction.

## Dating

The supplied MCMCtree workflow applies a soft B(0.05,0.10) secondary calibration to the D-CGK root, with one time unit=100 Ma. This is not the CGK crown calibration. It uses a fixed topology, an IQ-TREE likelihood/Hessian bundle, and an IQ-TREE-compatible PAML build. The original instructions describe prior/posterior chains and a longer chain; their completion and convergence must be assessed from actual logs. The historical concatenation has 18,785 loci, one more than the 18,784-locus topology set (GR02G1988); do not conceal that difference.

The plotting task maps HPD intervals to tree nodes by descendant-tip sets. Tree branch lengths are multiplied by 100; CSV ages/HPD endpoints are already in Ma and are not rescaled again.
