# Six-group SNaQ workflow

Use Julia 1.10+ with R available, then run setup.jl once to install the package versions specified by the supplied workflow.

Set CGK_GENE_TREES to your filtered rooted gene-tree file. Set CGK_SNAQ_GROUPS to an external headerless two-column TSV containing sample ID and group. Required groups are C1, C2, G1, G2G3, K, and D5. Optionally set CGK_SNAQ_OUTPUT to a fresh results directory, then run bash 06_TopologyWeightingAndNetworks/SNaQ/run.sh.

The workflow validates 18,784 trees with 40 matching tips, calculates 15 quartet sets, and searches hmax=0:3 with 30 searches per setting. Output folders must be new. The start topology and seeds follow the supplied research workflow. Julia inference was not rerun during repository preparation.

K9 is pooled in K, so the grouping cannot independently test a K9-specific hybrid origin. Gamma values are inheritance probabilities, not support values. Better pseudolikelihood fit alone does not establish a unique historical scenario. Inspect convergence across searches, model complexity, and identifiability before interpretation.
