# Software and attribution

The repository collects author scripts and selected third-party helper copies supplied with the analysis project. Cite the manuscript and the underlying methods actually used. No new blanket license is assigned to external code or data.

| Purpose | Software / upstream |
| --- | --- |
| Annotation and synteny | Liftoff, gffread, BEDOPS, GENESPACE, OrthoFinder, MCScanX |
| Read processing | Trimmomatic, BWA, SAMtools, Sentieon (licensed software) |
| Nuclear phylogenies | BamBam, MAFFT, trimAl, IQ-TREE, Newick Utilities, ASTRAL |
| Discordance | PhyParts; phyloscripts plotting helpers: https://github.com/mossmatters/phyloscripts |
| Plastomes | GetOrganelle, GeSeq, BCFtools, author cpdna_gene_extract.py |
| SNP coordinates | transanno: https://github.com/informationsea/transanno |
| Population structure | PLINK and LEA |
| Allele sharing | ADMIXTOOLS 2: https://github.com/uqrmaie1/admixtools |
| Topology weighting | Twisst, Simon H. Martin and Steven M. Van Belleghem: https://github.com/simonhmartin/twisst |
| Network inference | PhyloNetworks, SNaQ, PhyloPlots, RCall |
| Dating | IQ-TREE dating interface, compatible PAML/MCMCtree build, ETE3, Tracer |
| K-mer workflow | Kraken2, mirabait/MIRA, KmerCity, Snakemake, containers |
| Alignment statistics | AMAS, Marek Borowiec: https://github.com/marekborowiec/AMAS |
| Maps | Natural Earth boundaries, sf, rnaturalearth, ozmaps |
| Figures | tidyverse, ape, ggtree/treeio/tidytree, ggtreeExtra, scatterpie, patchwork, ggtext, cowplot |

The retained production module names record versions available on the original cluster. scripts/install_packages.R is a convenience helper and does not pin an exact computational environment. sessionInfo.txt from a completed plotting task records that local run. SNaQ setup pins the versions in the supplied workflow; final environment lockfiles should be generated on the inference host.

Avoid executing historical source scripts wholesale: some are notebooks containing multiple independent experiments. Install third-party programs from their upstream sources and preserve their licenses when redistributing them.

## Credential redaction

Before publication, hard-coded Sentieon license configuration was removed from the existing plastome README and collected production scripts. Configure licensing privately in the execution environment. No passwords, access tokens, API keys, license values, or license-server endpoints are included in this update. Source files outside this staging copy were not edited. Git history predating this update is not rewritten.
