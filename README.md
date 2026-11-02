# Revisiting homoploid hybrid speciation in Australian cotton (*Gossypium*) species

Analysis code supporting the CGK Australian cotton manuscript, covering sections *Sturtia* (C genome), *Hibiscoidea* (G genome), and *Grandicalyx* (K genome).

## Abstract

One of the earliest described cases of putative homoploid hybrid speciation was 35 years ago for the Australian cotton species, *Gossypium bickii*. This inference was based on discordance between chloroplast- and nuclear-based phylogenetic reconstructions, a type of incongruence that has become a relatively common observation in plants. Here we reevaluate evidence bearing on the evolutionary history of *G. bickii* in the context of an expanded sampling of all but one of the 17 described Australian cotton species, using whole-genome resequencing data based on 18,784 single-copy nuclear genes and entire plastome sequences. Genome-wide phylogenomic analyses resolved three well-defined sections (*Sturtia*, *Hibiscoidea* and *Grandicalyx*) and recapitulate the previously reported discordance between nuclear and plastid phylogenies, while providing greater resolution of interspecific relationships among the Australian cotton species. Although plastome inferences mirror phylogenetic discordance inferred earlier for *G. bickii* and *G. cunninghamii*, genome-wide nuclear data did not reveal compelling signals of interspecific introgression, perhaps because of population genetic nuclear swamping by a quantitatively larger paternal population and by subsequent genomic divergence. A unique chromosomal reciprocal translocation revealed by comparisons of genome assemblies supports the monophyly of the Australian clade. All analyses, including genome-wide phylogenetics and dating estimation, support a narrative in which there was early and rapid diversification of the three Australian sections, accompanied by early intersectional reticulation of plastomes without residual evidence in the nuclear genome.

## Analyses

The numbered folders group code by analysis type. Each contains a README describing the workflow, input requirements, and main entry points.

### [00_ReferenceGenomesAndSynteny](00_ReferenceGenomesAndSynteny)

Reference indexing, annotation transfer, orthology, chromosome synteny, and coordinate chains.

### [01_ReadProcessingAndMapping](01_ReadProcessingAndMapping)

Read trimming and reference-mapping comparisons.

### [02_NuclearPhylogeny](02_NuclearPhylogeny)

Consensus gene sequences, alignment statistics, gene trees, ASTRAL species trees, and PhyParts discordance.

### [03_PlastomePhylogeny](03_PlastomePhylogeny)

Plastome assembly, coding-sequence extraction, alignment, and plastome tree reconstruction.

### [04_SNPCallingAndFiltering](04_SNPCallingAndFiltering)

Reference-specific variant calls, coordinate liftover, merging, and SNP filtering.

### [05_PopulationStructure](05_PopulationStructure)

PLINK PCA, LEA ancestry inference, missingness, and genetic-structure figures.

### [06_TopologyWeightingAndNetworks](06_TopologyWeightingAndNetworks)

Twisst topology weights and SNaQ quartet-based network inference.

### [07_IntrogressionAndKmers](07_IntrogressionAndKmers)

ADMIXTOOLS f3 tests and KmerCity k-mer overlap summaries.

### [08_DivergenceDating](08_DivergenceDating)

MCMCtree input preparation, posterior runs, and dated-tree visualization.

### [09_SpeciesDistribution](09_SpeciesDistribution)

Australian native cotton distribution and Grandicalyx clade maps.

### [99_Supplemental](99_Supplemental)

Shared R runner, package installation helper, external-input instructions, methods, software attribution, validation notes, manuscript figure crosswalk, and earlier workflow notes.

## Getting started

1. Install the software needed for your analysis; see [software and attribution](99_Supplemental/docs/SOFTWARE.md). The optional R helper is `99_Supplemental/scripts/install_packages.R`.
2. Supply the external input files described in [INPUTS.md](99_Supplemental/docs/INPUTS.md). Raw reads and processed datasets are not bundled here.
3. Run plotting and summary tasks from the repository root, for example:

```bash
Rscript 99_Supplemental/scripts/run_analysis.R phylogeny /path/to/Ozcotton
Rscript 99_Supplemental/scripts/run_analysis.R structure /path/to/Ozcotton
Rscript 99_Supplemental/scripts/run_analysis.R kmer /path/to/Ozcotton
```

`CGK_DATA_ROOT` can replace the second argument. An optional third argument sets the output root; by default, outputs and copied working inputs are written under `outputs/<task>/work/`. See the individual analysis READMEs for additional tasks and inference commands.

## Manuscript and reproducibility

The abstract above is from the supplied manuscript draft; final publication details and sequence accessions will be added when available. The [figure crosswalk](99_Supplemental/docs/MANUSCRIPT_CROSSWALK.md) links manuscript analyses to code; figure numbering remains provisional.

Workflow scripts are research templates. Replace `/path/to/` and `SAMPLE_` placeholders, configure software and resources, and supply sample lists before running cluster jobs. Alternative historical runs are retained in labeled subfolders. The combined nuclear/plastome plotting task is in `02_NuclearPhylogeny/phylogeny.R`. The Twisst R task plots recorded draft percentages; fresh inference uses the Twisst wrapper.

Validation and its limits are recorded in [VALIDATION.md](99_Supplemental/docs/VALIDATION.md). The full raw-read workflow and network inference were not rerun during repository organization. Private paths, passwords, tokens, and Sentieon license/API configuration are excluded from the current files; earlier Git history has not been rewritten.

Please cite the manuscript when bibliographic details are available and cite the underlying software. Third-party code retains its authorship and licensing; no new blanket license is assigned.
