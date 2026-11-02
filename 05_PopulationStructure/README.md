# 05_PopulationStructure

PLINK PCA, LEA ancestry inference, missingness, and genetic-structure figures.

## Main code

- [structure.R](structure.R)
- [workflow/](workflow/): supporting cluster workflows.

## Plotting and summary tasks

Run from the repository root with the external input directory:

```bash
Rscript 99_Supplemental/scripts/run_analysis.R structure /path/to/Ozcotton
```

## Inputs and execution

See [external inputs](../99_Supplemental/docs/INPUTS.md), [methods](../99_Supplemental/docs/METHODS.md), and [software](../99_Supplemental/docs/SOFTWARE.md). Supply the reference files, reads, alignments, metadata, or processed summaries required by this stage. Files under `workflow/` and `historical/` retain research alternatives; configure placeholders and execute the relevant stages individually.

[Back to repository overview](../README.md)
