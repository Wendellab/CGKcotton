# Replot an existing GENESPACE run; raw peptide/BED inputs remain external.
library(GENESPACE)
gpar <- readRDS("genespace_output.rds")
# An external serialized object may refer to its original GENESPACE directory.
# Set CGK_GENESPACE_WD to the complete run directory if it has moved.
wd <- Sys.getenv("CGK_GENESPACE_WD")
if (nzchar(wd)) gpar$paths$wd <- normalizePath(wd, mustWork = TRUE)
invchr <- data.frame(
 genome = c("K2_HAUreference", "C1_HAUreference", "G2_CRIreference", "G1_HAUreference", "C1_HAUreference", "C1_HAUreference", "D5_T2T_PKUreference", "D5_T2T_PKUreference", "G2_CRIreference", "G1_HAUreference", "D5_T2T_PKUreference", "G2_CRIreference", "K2_HAUreference", "K2_HAUreference", "G2_CRIreference", "C1_HAUreference", "K2_HAUreference", "G1_HAUreference", "C1_HAUreference"),
 chr = c("Chr01", "Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Ch05", "Ch06", "Chr07", "Chr08", "Ch08", "Chr09", "Chr10", "Chr11", "Chr12", "Chr12", "Chr13", "Chr13", "Chr13"))
pdf("Fig4_GENESPACE_synteny.pdf", width = 13, height = 6)
plot_riparian(gsParam = gpar, minChrLen2plot = 10, invertTheseChrs = invchr,
 refGenome = "D5_T2T_PKUreference", chrLabFontSize = 6, reorderBySynteny = FALSE,
 genomeIDs = c("D5_T2T_PKUreference", "C1_HAUreference", "G1_HAUreference", "G2_CRIreference", "K2_HAUreference"),
 forceRecalcBlocks = FALSE, useOrder = FALSE)
dev.off()
