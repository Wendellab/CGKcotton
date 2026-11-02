# Manuscript-to-code crosswalk

Based on the supplied 34-page manuscript PDF inspected on 2026-11-01. Figure numbering is provisional: text and captions disagree in places. Outputs use descriptive names when a final panel number is uncertain.

| Manuscript content | R runner task / code | Primary production source |
| --- | --- | --- |
| Fig. 1: native distribution | distribution | 09_SpeciesDistribution/distribution.R |
| Fig. 2: morphological plate | not included; assembled separately from source photographs | not included |
| Fig. 3: reference mapping comparison | mapping | 01_ReadProcessingAndMapping/workflow/mapping/ |
| Fig. 4: orthology and chromosome synteny | synteny (requires external GENESPACE run) | 00_ReferenceGenomesAndSynteny/workflow/ |
| Fig. 5a: ASTRAL tree and PhyParts pies | phylogeny | 02_NuclearPhylogeny/workflow/03_genetrees/ |
| Fig. 5b: whole-plastome tree | phylogeny | 03_PlastomePhylogeny/workflow/05_plastometrees/ |
| Fig. 6: missingness, PCA, LEA | structure | 05_PopulationStructure/workflow/PLINK/ |
| Fig. 7: topology weights | twisst (recorded values); 06_TopologyWeightingAndNetworks/Twisst/run_twisst.py (new inference) | 06_TopologyWeightingAndNetworks/Twisst/ |
| Fig. 7: SNaQ network | 06_TopologyWeightingAndNetworks/SNaQ/ | production and workspace SNaQ sources |
| Fig. 7: pairwise k-mer sharing | kmer | 07_IntrogressionAndKmers/workflow/KmerCity/ |
| Fig. S1: alignment summaries | alignment_stats | author-retained 18,784-locus list and AMAS summaries |
| Fig. S2: dated tree | dating_plot | 08_DivergenceDating/workflow/ |
| Fig. S3: Grandicalyx clade maps | distribution_clades | Desktop distribution script |
| Fig. S4: plastome coding sequences | phylogeny | genefasta/cpdna_gene_extract.py and plastome.sh |
| Fig. S5: LEA cross entropy | structure | external saved best-run table; production LEA code |
| Fig. S6: f3 tests and full k-mer sharing | f3 and kmer | external f2 blocks and KmerCity intersections |

## Processing order

1. Reference preparation and annotation transfer; identify conserved single-copy orthologs.
2. Trim reads, compare reference mappings, and retrieve consensus gene sequences.
3. Align/trim loci, infer gene trees, filter/root them, infer ASTRAL tree, and summarize discordance.
4. Assemble/reconstruct plastomes; remove one IR copy; infer whole-plastome and coding-sequence trees.
5. Reference-specific genotype calls, liftover to G2 coordinates, normalize/merge, filter SNPs, and infer PCA/LEA structure.
6. Compare topology weights, estimate networks with SNaQ, calculate f3, and summarize k-mer overlap.
7. Date the fixed topology with the documented secondary root calibration and inspect chain diagnostics.
8. Produce manuscript figures and audit counts against the final manuscript.
