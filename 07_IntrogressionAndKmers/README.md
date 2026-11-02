# 07_IntrogressionAndKmers

ADMIXTOOLS f3 tests and KmerCity k-mer overlap summaries.

## Main code

- [f3.R](f3.R)
- [kmer.R](kmer.R)
- [workflow/](workflow/): supporting cluster workflows.

## Plotting and summary tasks

Run from the repository root with the external input directory:

```bash
Rscript 99_Supplemental/scripts/run_analysis.R f3 /path/to/Ozcotton
Rscript 99_Supplemental/scripts/run_analysis.R kmer /path/to/Ozcotton
```

## Inputs and execution

See [external inputs](../99_Supplemental/docs/INPUTS.md), [methods](../99_Supplemental/docs/METHODS.md), and [software](../99_Supplemental/docs/SOFTWARE.md). Supply the reference files, reads, alignments, metadata, or processed summaries required by this stage. Files under `workflow/` and `historical/` retain research alternatives; configure placeholders and execute the relevant stages individually.

[Back to repository overview](../README.md)
