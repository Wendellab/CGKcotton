# Production workflow guide

Production scripts are grouped by analysis in the numbered folders.

- [Reference genomes and synteny](../../00_ReferenceGenomesAndSynteny/): Reference indexing, annotation transfer, orthology, chromosome synteny, and coordinate chains.
- [Read processing and mapping](../../01_ReadProcessingAndMapping/): Read trimming and reference-mapping comparisons.
- [Nuclear phylogeny](../../02_NuclearPhylogeny/): Consensus gene sequences, alignment statistics, gene trees, ASTRAL species trees, and PhyParts discordance.
- [Plastome phylogeny](../../03_PlastomePhylogeny/): Plastome assembly, coding-sequence extraction, alignment, and plastome tree reconstruction.
- [SNP calling and filtering](../../04_SNPCallingAndFiltering/): Reference-specific variant calls, coordinate liftover, merging, and SNP filtering.
- [Population structure](../../05_PopulationStructure/): PLINK PCA, LEA ancestry inference, missingness, and genetic-structure figures.
- [Topology weighting and networks](../../06_TopologyWeightingAndNetworks/): Twisst topology weights and SNaQ quartet-based network inference.
- [Introgression and k-mers](../../07_IntrogressionAndKmers/): ADMIXTOOLS f3 tests and KmerCity k-mer overlap summaries.
- [Divergence dating](../../08_DivergenceDating/): MCMCtree input preparation, posterior runs, and dated-tree visualization.
- [Species distribution](../../09_SpeciesDistribution/): Australian native cotton distribution and Grandicalyx clade maps.

These are generalized research templates. Private paths and sample identifiers have been replaced with placeholders. Supply file lists and configure software, resources, and licensing privately. No cluster jobs were submitted during repository organization.

The gene-reference and species-reference SNP routes are alternatives, as are PLINK and PLINK_nomissing. Earlier SNaQ attempts are labeled historical; the combined workflow is in 06_TopologyWeightingAndNetworks/SNaQ/. Some shell files contain mixed research notes and are not standalone executable jobs. Inspect commands that remove or overwrite intermediate files before use.

The numbered layout categorizes analysis types; it is not a single automatic execution chain. Input paths inside production commands refer to the external analysis workspace, not this code repository.
