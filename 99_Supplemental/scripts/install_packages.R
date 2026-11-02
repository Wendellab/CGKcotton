# Optional installation helper; this script is never run automatically.
cran <- c("tidyverse", "sf", "rnaturalearth", "rnaturalearthdata", "ozmaps", "patchwork", "ggtext",
          "ape", "phangorn", "scatterpie", "gridExtra", "ggrepel", "cowplot", "ggnewscale",
          "reshape2", "png", "ggpubr", "ggimage", "aplot", "RColorBrewer", "remotes")
missing <- cran[!vapply(cran, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager", repos = "https://cloud.r-project.org")
bioc <- c("ggtree", "treeio", "tidytree", "ggtreeExtra", "LEA")
missing <- bioc[!vapply(bioc, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) BiocManager::install(missing, ask = FALSE, update = FALSE)
# GitHub-hosted dependencies: inspect upstream requirements before installation.
if (!requireNamespace("admixtools", quietly = TRUE)) remotes::install_github("uqrmaie1/admixtools", upgrade = "never")
# GENESPACE is required only for the optional external synteny task:
# remotes::install_github("jtlovell/GENESPACE", upgrade = "never")
