# 03_PlastomePhylogeny

Plastome assembly, coding-sequence extraction, alignment, and plastome tree reconstruction.

## Main code

- [workflow/](workflow/): cluster workflow templates.

## Plotting and summary tasks

Run from the repository root with the external input directory:

```bash
Rscript 99_Supplemental/scripts/run_analysis.R phylogeny /path/to/Ozcotton
```

The shared `phylogeny` task draws nuclear and plastome trees together; its R code is in [02_NuclearPhylogeny](../02_NuclearPhylogeny/phylogeny.R).

## Inputs and execution

See [external inputs](../99_Supplemental/docs/INPUTS.md), [methods](../99_Supplemental/docs/METHODS.md), and [software](../99_Supplemental/docs/SOFTWARE.md). Supply the reference files, reads, alignments, metadata, or processed summaries required by this stage. Files under `workflow/` and `historical/` retain research alternatives; configure placeholders and execute the relevant stages individually.

[Back to repository overview](../README.md)
