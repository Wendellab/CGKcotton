# 02_NuclearPhylogeny

Consensus gene sequences, alignment statistics, gene trees, ASTRAL species trees, and PhyParts discordance.

## Main code

- [alignment_stats.R](alignment_stats.R)
- [phylogeny.R](phylogeny.R)
- [workflow/](workflow/): supporting cluster workflows.

## Plotting and summary tasks

Run from the repository root with the external input directory:

```bash
Rscript 99_Supplemental/scripts/run_analysis.R alignment_stats /path/to/Ozcotton
Rscript 99_Supplemental/scripts/run_analysis.R phylogeny /path/to/Ozcotton
```

## Inputs and execution

See [external inputs](../99_Supplemental/docs/INPUTS.md), [methods](../99_Supplemental/docs/METHODS.md), and [software](../99_Supplemental/docs/SOFTWARE.md). Supply the reference files, reads, alignments, metadata, or processed summaries required by this stage. Files under `workflow/` and `historical/` retain research alternatives; configure placeholders and execute the relevant stages individually.

[Back to repository overview](../README.md)
