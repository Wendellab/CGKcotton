# Production code from the research drive

These files were read from /path/to/CGK_PROJECT for the GitHub update. The directory structure mirrors that project. Original files on Z: were not modified and no jobs were submitted. Scripts retain historical module names, resource requests, and alternative attempts. Private paths and sample identifiers have been replaced with placeholders; configure these before execution.

| Manuscript stage | Production folder / entry points |
| --- | --- |
| Read trimming | 00_trim.sh, 01_trim2.sh, 02_trim3.sh (supply filename lists externally) |
| Reference and annotation preparation | 00_ref_GCF_0256985451/reference_idx*.sh; 04_liftoff_genespace/; 05_genespace/ |
| Reference alignment/liftover chains | 00_ref_GCF_0256985451/06_reference_minimap/ |
| Plastome assembly and phylogeny | 02_getorg/getorgenelle.sh; 05_plastometrees/plastome.sh; genefasta/cpdna_gene_extract.py |
| Mapping-rate comparison | 03_gvcfs_vcf_new/01_mappingrate.sh and 02_mappingrate.sh |
| Consensus sequences and per-locus trees | 04_bam2fasta/Bam2consensus.sh; bambam*.sh; AMAS.sh |
| ASTRAL and PhyParts | 04_bam2fasta/03_genetrees/Astral.sh; phyparts/phypart.sh |
| Topology weighting | 04_bam2fasta/03_genetrees/phyparts/twisst/ |
| SNaQ | 04_bam2fasta/03_genetrees/phyparts/SNAQ/; portable combined workflow in ../snaq/ |
| Divergence dating | 04_bam2fasta/03_genetrees/phyparts/MCMCtree/mcmctree_5to10Ma/ |
| Gene-reference SNP route (alternative) | 05_genevcf/ |
| Species-reference SNP calls/liftover | 06_species_specific/*step1*; *step2*; *step3* |
| SNP merging/filtering | 06_species_specific/07_finalmerg.sh and 00_finalmerge/ |
| PLINK and LEA | 06_species_specific/00_finalmerge/PLINK/ and PLINK_nomissing/ |
| Read filtering and KmerCity | 07_Kmer/step0_readfilter.sh through step3_OZkmer.sh |

## Important distinctions

- These are generalized production templates, not a new automatically executable pipeline. Commands may reference obsolete intermediate filenames, manually selected samples, external tool installations, or alternative runs.
- The 05_genevcf route and reference-specific 06_species_specific route are alternatives, not sequential stages to concatenate blindly.
- The PLINK and PLINK_nomissing folders are separate analyses. Final manuscript correspondence requires checking the retained sample/variant sets.
- Some commands remove temporary/intermediate files or overwrite outputs. None were executed during repository organization.
- KmerCity's referenced config and some tools reside outside the project folder; see docs/INPUTS.md.
- Third-party copies such as Twisst, AMAS, and PhyParts plotting helpers retain their authorship. See docs/SOFTWARE.md.

Private paths, contact details, sample identifiers, and embedded Sentieon license configuration have been removed or generalized. Configure input paths, sample lists, and licensing privately.
