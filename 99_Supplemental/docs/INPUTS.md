# External input files

This is a code-only repository update. Processed datasets, raw reads, alignments, genotype matrices, f2 block arrays, and saved R sessions are not uploaded. The input files below must be supplied in an external Ozcotton directory. The runner copies the required files to its own outputs/ workspace before processing, leaving original files unchanged.

Set CGK_DATA_ROOT to that directory or pass it as argument 2:

    Rscript 99_Supplemental/scripts/run_analysis.R kmer "/path/to/Ozcotton"

## Expected external folder layout

| Folder | Required files |
| --- | --- |
| 00_Distribution | Ozcotton_1970to2025_NativeOnly.txt; cottonname.txt; optional Australian_states_10m.rds map cache |
| 01_genespaceoutput | n19028_all_trees_stat.txt; n18784_gene_list.csv |
| 03_astraltree | n18784_filter_trees_bs03_rt_astral_rt.tre; rename_ntDNA.txt; rename_cpDNA.txt; phyparts_pies.csv; DCGK_n18784.node.key; changed_n42_IRB_aln_noIRB_nogap_rt.treefile; cpDNA_supermatrix_nogap_rt.treefile |
| 03_astraltree/MCMCtreeoutput | Matching FigTree.tre and FigTree_HPD_nodes.csv |
| 04_KmerCity | n38_30mer.intersections |
| 04_KmerCity/f3f4 | CGK.RData containing f2_blocks |
| 04_KmerCity/SNPsOzcotton | CGKD_G2ref.eigenvec; CGKD_G2ref.eigenval; missing_individual.imiss; n18784_filter_trees_bs03_rt_astral_rt.tre; LEAstruture_n65.RData containing plot_list and kvalue |
| Data root itself | genespace_output.rds for optional synteny task; full GENESPACE working directory also required |

The f3 and structure scripts load saved RData into isolated environments and retrieve only the documented objects. Historical session dependencies have been replaced with explicit external inputs.

## Other production inputs

- Raw reads and final NCBI accessions, linked to the final Table S1.
- Reference FASTAs, annotations, Liftoff/GENESPACE BED and peptide files.
- BAMs, reference-specific GVCFs/VCFs, liftover chains, genotype masks, and final filtered SNP matrix.
- All per-locus alignments and the full 18,784-tree Newick file for Twisst/SNaQ reruns.
- Dating concatenation and matching IQ-TREE likelihood/control/Hessian files for posterior reruns.
- KmerCity config/OZconfig_n38.yaml, containers, databases, read subsampling settings/seeds, and clean reads. The referenced config lies outside the collected research-project folders.
- Original photographs and final plate composition; images are not republished.

## Distribution filtering

The supplied occurrence file covers 1970-2025 and has year, decimalLatitude, decimalLongitude, scientificName, genus, and specificEpithet columns. The general map uses it as supplied. The clade map restricts to the displayed Kimberley extent and WA polygon, retaining K9 separately in its NT inset. Coincident coordinates are plotted once per species; legend n counts retained records before location deduplication. Coastline/coordinate precision can exclude coastal records, so inspect exclusions before calling them errors.

Final GBIF download DOI, access date, filtering details, attribution, and licensing information remain for author curation.
