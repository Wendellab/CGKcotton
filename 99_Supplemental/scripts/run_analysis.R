# Run from any directory: Rscript 99_Supplemental/scripts/run_analysis.R mapping [data-root] [output-root]
args <- commandArgs(trailingOnly = TRUE)
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
repo <- normalizePath(file.path(dirname(sub("^--file=", "", script_arg[1])), "..", ".."), winslash = "/", mustWork = TRUE)
tasks <- c(distribution = "00_Distribution", distribution_clades = "00_Distribution",
           mapping = "05_mappingrate", alignment_stats = "01_genespaceoutput",
           phylogeny = "03_astraltree", structure = "04_KmerCity/SNPsOzcotton",
           kmer = "04_KmerCity", f3 = "04_KmerCity/f3f4", twisst = ".",
           dating_plot = "03_astraltree/MCMCtreeoutput", synteny = ".")
if (!length(args) || !args[1] %in% names(tasks)) stop("Choose: ", paste(names(tasks), collapse = ", "), call. = FALSE)
task <- args[1]
data_root <- if (length(args) >= 2) args[2] else Sys.getenv("CGK_DATA_ROOT")
if (!nzchar(data_root)) stop("Supply the external Ozcotton data root as argument 2 or set CGK_DATA_ROOT.", call. = FALSE)
data_root <- normalizePath(data_root, winslash = "/", mustWork = TRUE)
output_root <- if (length(args) >= 3) args[3] else file.path(repo, "outputs")
dir.create(output_root, recursive = TRUE, showWarnings = FALSE)
output_root <- normalizePath(output_root, winslash = "/", mustWork = TRUE)
cgk_work_root <- file.path(output_root, task, "work")
cgk_work_dir <- file.path(cgk_work_root, tasks[[task]])
dir.create(cgk_work_dir, recursive = TRUE, showWarnings = FALSE)
cgk_input <- function(relative) {
  candidates <- file.path(data_root, relative)
  hit <- candidates[file.exists(candidates)]
  if (!length(hit)) stop("Missing input: ", relative, ". See 99_Supplemental/docs/INPUTS.md.", call. = FALSE)
  normalizePath(hit[1], winslash = "/", mustWork = TRUE)
}
required <- list(
  distribution = c("00_Distribution/Ozcotton_1970to2025_NativeOnly.txt", "00_Distribution/cottonname.txt"),
  distribution_clades = "00_Distribution/Ozcotton_1970to2025_NativeOnly.txt",
  mapping = "05_mappingrate/mappingratecomparison.tsv",
  alignment_stats = c("01_genespaceoutput/n19028_all_trees_stat.txt", "01_genespaceoutput/n18784_gene_list.csv"),
  phylogeny = paste0("03_astraltree/", c("n18784_filter_trees_bs03_rt_astral_rt.tre", "rename_ntDNA.txt", "rename_cpDNA.txt", "phyparts_pies.csv", "DCGK_n18784.node.key", "changed_n42_IRB_aln_noIRB_nogap_rt.treefile", "cpDNA_supermatrix_nogap_rt.treefile")),
  structure = c(paste0("04_KmerCity/SNPsOzcotton/", c("CGKD_G2ref.eigenval", "CGKD_G2ref.eigenvec", "missing_individual.imiss", "n18784_filter_trees_bs03_rt_astral_rt.tre", "LEAstruture_n65.RData")), "03_astraltree/rename_ntDNA.txt"),
  kmer = c("04_KmerCity/n38_30mer.intersections", "03_astraltree/rename_ntDNA.txt"),
  f3 = "04_KmerCity/f3f4/CGK.RData",
  twisst = character(),
  dating_plot = c("03_astraltree/MCMCtreeoutput/FigTree.tre", "03_astraltree/MCMCtreeoutput/FigTree_HPD_nodes.csv", "03_astraltree/rename_ntDNA.txt"),
  synteny = "genespace_output.rds")
for (relative in required[[task]]) {
  destination <- file.path(cgk_work_root, relative)
  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  if (!file.copy(cgk_input(relative), destination, overwrite = TRUE)) stop("Could not stage ", relative)
}
if (task == "distribution_clades") {
  map_cache <- file.path(data_root, "00_Distribution/Australian_states_10m.rds")
  if (file.exists(map_cache)) file.copy(map_cache, file.path(cgk_work_dir, basename(map_cache)), overwrite = TRUE)
}
setwd(cgk_work_dir)
set.seed(20261101)
analysis_paths <- c(synteny = "00_ReferenceGenomesAndSynteny/synteny.R",
                    mapping = "01_ReadProcessingAndMapping/mapping.R",
                    alignment_stats = "02_NuclearPhylogeny/alignment_stats.R",
                    phylogeny = "02_NuclearPhylogeny/phylogeny.R",
                    structure = "05_PopulationStructure/structure.R",
                    twisst = "06_TopologyWeightingAndNetworks/twisst.R",
                    f3 = "07_IntrogressionAndKmers/f3.R",
                    kmer = "07_IntrogressionAndKmers/kmer.R",
                    dating_plot = "08_DivergenceDating/dating_plot.R",
                    distribution = "09_SpeciesDistribution/distribution.R",
                    distribution_clades = "09_SpeciesDistribution/distribution_clades.R")
source(file.path(repo, analysis_paths[[task]]), local = .GlobalEnv, chdir = FALSE)
writeLines(capture.output(sessionInfo()), file.path(cgk_work_dir, "sessionInfo.txt"))
message("Completed ", task, "; outputs: ", cgk_work_dir)

quit(save = "no", status = 0)
