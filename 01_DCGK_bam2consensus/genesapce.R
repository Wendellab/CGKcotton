library(GENESPACE, lib.loc = "/lustre/hdd/LAS/jfw-lab/weixuan/00_BioinformaticTools/rpackage")

# Initialize
gpar <- init_genespace(
  wd = "/lustre/hdd/LAS/jfw-lab/weixuan/10_Australian_Reseq/00_ref_GCF_0256985451/05_genespace", 
  path2mcscanx = "/lustre/hdd/LAS/jfw-lab/weixuan/00_BioinformaticTools/MCScanX")

gpar$params$nCores <- 40

# Run genespace
gpar <- run_genespace(gsParam = gpar, overwrite = TRUE)

# Plot riparian
ripd <- plot_riparian(
  gsParam = gpar,
  refGenome = "D5_T2T_PKUreference", 
  useRegions = FALSE)

# Save plot as PDF
pdf("riparian_plot.pdf", width = 10, height = 8)
print(ripd)
dev.off()

# Save genespace object for later
save(gpar, file = "genespace_output.RData")
saveRDS(gpar, file = "genespace_output.rds")


ggthemes <- ggplot2::theme(
  panel.background = ggplot2::element_rect(fill = "white"))
  
library(RColorBrewer)

# Define a base gradient
customPal <- colorRampPalette(c(
  "#E69F00", # darkorange
  "#56B4E9", # skyblue
  "#0072B2", # darkblue
  "#CC79A7", # purple/pink
  "#D55E00", # darkred
  "#F0E442"  # yellowish/salmon alternative for colorblind
))

  

invchr <- data.frame(
  genome = c("K2_HAUreference", "C1_HAUreference", "G2_CRIreference", "G1_HAUreference", "C1_HAUreference", "C1_HAUreference", "D5_T2T_PKUreference",
  "D5_T2T_PKUreference", "G2_CRIreference", "G1_HAUreference", "D5_T2T_PKUreference", "G2_CRIreference", 
  "K2_HAUreference","K2_HAUreference", "G2_CRIreference", "C1_HAUreference", "K2_HAUreference", "G1_HAUreference", "C1_HAUreference" ), 
  chr = c("Chr01", "Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Ch05", "Ch06", "Chr07", "Chr08","Ch08","Chr09","Chr10", "Chr11", "Chr12", "Chr12", "Chr13", "Chr13", "Chr13"))

#RefChrOrder <- c(paste0("Ch0", 1:5), "Ch13", paste0("Ch0", 6:9), paste0("Ch", 10:12))

  
pdf("final_genespace_plot.pdf", width = 8, height = 6)
plot_riparian(
  gsParam = gpar, 
  minChrLen2plot = 10,
  invertTheseChrs = invchr,
  refGenome = "D5_T2T_PKUreference",
  chrLabFontSize = 6,
  reorderBySynteny = FALSE,
  genomeIDs = c(  "D5_T2T_PKUreference", "C1_HAUreference", "G1_HAUreference", "G2_CRIreference" , "K2_HAUreference"), 
  forceRecalcBlocks = FALSE,
#  customRefChrOrder = RefChrOrder
#  palette = customPal,
#  braidAlpha = .75,
#  chrFill = "lightgrey",
#  addThemes = ggthemes
)
dev.off()

pdf("final_genespace_plot2.pdf", width = 13, height = 6)
plot_riparian(
  gsParam = gpar, 
  minChrLen2plot = 10,
  invertTheseChrs = invchr,
  refGenome = "D5_T2T_PKUreference",
  chrLabFontSize = 6,
  reorderBySynteny = FALSE,
  genomeIDs = c(  "D5_T2T_PKUreference", "C1_HAUreference", "G1_HAUreference", "G2_CRIreference" , "K2_HAUreference"), 
  forceRecalcBlocks = FALSE,
  useOrder = FALSE
#  customRefChrOrder = RefChrOrder
#  palette = customPal,
#  braidAlpha = .75,
#  chrFill = "lightgrey",
#  addThemes = ggthemes
)
dev.off()
