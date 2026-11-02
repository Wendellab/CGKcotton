# 06_TopologyWeightingAndNetworks

Twisst topology weights and SNaQ quartet-based network inference.

## Main code

- [twisst.R](twisst.R)
- [Twisst/](Twisst/): inference wrapper and upstream implementation.
- [SNaQ/](SNaQ/): combined network workflow and setup.
- [historical/SNaQ/](historical/SNaQ/): earlier alternative scripts.

## Plotting and summary tasks

Run from the repository root with the external input directory:

```bash
Rscript 99_Supplemental/scripts/run_analysis.R twisst /path/to/Ozcotton
```

## Fresh inference

```bash
python 06_TopologyWeightingAndNetworks/Twisst/run_twisst.py /path/to/gene_trees.tre /path/to/new_output --groups /path/to/groups.tsv
```

The headerless group TSV uses C1, C2, G1, G2G3, K, and D5. The R task plots recorded percentages and is separate from this inference wrapper. For network inference, follow the [SNaQ instructions](SNaQ/README.md).

## Inputs and execution

See [external inputs](../99_Supplemental/docs/INPUTS.md), [methods](../99_Supplemental/docs/METHODS.md), and [software](../99_Supplemental/docs/SOFTWARE.md). Supply the reference files, reads, alignments, metadata, or processed summaries required by this stage. Files under `workflow/` and `historical/` retain research alternatives; configure placeholders and execute the relevant stages individually.

[Back to repository overview](../README.md)
