# Australian cotton phylogenomics: C, G, and K genomes

Code supporting the manuscript on Australian cotton phylogeny and historical reticulation, covering sections Sturtia, Hibiscoidea, and Grandicalyx.

This update contains analysis code and workflow documentation. Raw reads, processed datasets, sample metadata tables, personal contact details, private cluster paths, passwords, tokens, and Sentieon licensing/API configuration are not included.

## Contents

- analysis/: R entry points for distribution maps, reference mapping, synteny, nuclear/plastome phylogenies, PCA/LEA, topology weights, f3, k-mer sharing, and dated-tree plotting.
- scripts/: analysis runner and optional package installation helper.
- pipelines/production/: generalized versions of supplied cluster workflows, organized by their original analysis stages.
- pipelines/snaq/: combined six-group network-inference entry point.
- pipelines/twisst/: optional topology-weighting rerun wrapper.
- docs/: [figure crosswalk](docs/MANUSCRIPT_CROSSWALK.md), [inputs](docs/INPUTS.md), [methods](docs/METHODS.md), [software](docs/SOFTWARE.md), and [validation](docs/VALIDATION.md).
- 00_plastome/ and 01_DCGK_bam2consensus/: earlier workflow material, with private paths/contact/licensing details removed.

## Run an R analysis

Supply your external Ozcotton input folder as argument 2:

    Rscript scripts/run_analysis.R mapping /path/to/Ozcotton
    Rscript scripts/run_analysis.R alignment_stats /path/to/Ozcotton
    Rscript scripts/run_analysis.R phylogeny /path/to/Ozcotton
    Rscript scripts/run_analysis.R structure /path/to/Ozcotton
    Rscript scripts/run_analysis.R kmer /path/to/Ozcotton
    Rscript scripts/run_analysis.R f3 /path/to/Ozcotton
    Rscript scripts/run_analysis.R twisst /path/to/Ozcotton
    Rscript scripts/run_analysis.R dating_plot /path/to/Ozcotton
    Rscript scripts/run_analysis.R distribution /path/to/Ozcotton
    Rscript scripts/run_analysis.R distribution_clades /path/to/Ozcotton

CGK_DATA_ROOT can replace argument 2. A third argument sets the output root. The runner stages input copies under outputs/<analysis>/work/ and records sessionInfo.txt. Original datasets are not overwritten. See docs/INPUTS.md for exact filenames. scripts/install_packages.R is an optional convenience helper, not a locked environment.

The synteny task additionally needs a full external GENESPACE run. The twisst plotting task uses recorded draft percentages; it does not perform new inference. For inference, use pipelines/twisst/run_twisst.py with an external gene-tree file and --groups sample/group TSV. SNaQ also requires external gene trees and a group-assignment TSV.

## Publication and workflow limitations

Production files are research templates: replace /path/to/ placeholders, configure software/modules, and supply sample lists externally before use. Sample identifiers in historical examples have been replaced with SAMPLE_ placeholders. Three historical shell notebooks contain mixed prose/R/output and are not standalone shell scripts. No cluster jobs were submitted, and the full raw-read workflow has not been rerun.

K4 is displayed with Clade 1 for visualization only because genetic data were unavailable; K9 is plotted in an NT inset and included in that legend. Shared k-mers and PCA position alone do not establish introgression. Gamma values in a network are inheritance probabilities, not bootstrap support.

Original research-drive and Desktop source files were not modified. Credential redaction here does not remove material from older Git history. Final accession records, occurrence-data attribution, environment versions, and manuscript figure numbering remain for author curation.

Please cite the manuscript when final bibliographic details are available and cite the software actually used. Third-party programs retain their authorship and licenses; this update adds no new blanket license.
