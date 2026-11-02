# Plot the completed Australian cotton MCMCtree analysis.
# Run this script in RStudio on your Windows computer (with Z: mounted).

library(ape)
library(tidytree)
library(dplyr)
library(ggplot2)
library(ggtree)
library(treeio)
library(stringr)

# 1. Open the folder containing the completed dated tree.
setwd(cgk_work_dir)

# Read the tree topology and branch lengths.
# The node-age CSV was generated from THIS FigTree.tre by the plotting helper.
# MCMCtree writes UTREE in its NEXUS header; some ape versions cannot read it.
# Extract the Newick statement and remove its bracket annotations.
# Ages and HPD bars are read separately from the matching CSV below.
tree_text <- paste(readLines("FigTree.tre", warn = FALSE), collapse = " ")
tree_text <- sub("(?is)^.*?\\b(?:UTREE|TREE)\\s+[^=]+?=\\s*", "",
                 tree_text, perl = TRUE)
tree_text <- sub(";.*$", ";", tree_text)
tree_text <- gsub("\\[[^]]*\\]", "", tree_text)


#######################################################
tree1 <- read.tree(text = tree_text)
write.tree(tree1, file = "FigTree_clean.nwk")
stopifnot(inherits(tree1, "phylo"), Ntip(tree1) == 40)
ages <- read.csv("FigTree_HPD_nodes.csv", stringsAsFactors = FALSE)

# Read your existing sample names and section colors.
sample_name <- read.delim(
  file.path(cgk_work_root, "03_astraltree/rename_ntDNA.txt"),
  stringsAsFactors = FALSE
)

sample_name <- sample_name %>% rename(label = Label)
stopifnot(!anyDuplicated(sample_name$label))

# 2. Convert ONLY the tree branch lengths from 100-Ma units into Ma.
# The CSV ages and HPD limits are ALREADY in Ma: do not multiply them again.
tree1$edge.length <- tree1$edge.length * 100

# 3. Match CSV clades to this tree by their descendant samples.
# plot_node_id in the CSV is NOT an ape node number or a PAML t_n number.
ages$node <- NA_integer_

for (i in 1:nrow(ages)) {
  tips <- strsplit(ages$descendant_tips[i], ";", fixed = TRUE)[[1]]
  stopifnot(all(tips %in% tree1$tip.label))
  ages$node[i] <- getMRCA(tree1, tips)
  clade <- extract.clade(tree1, ages$node[i])
  stopifnot(setequal(clade$tip.label, tips))
}
stopifnot(!anyDuplicated(ages$node))

# 4. Make the tree plot and attach the sample names.
p <- ggtree(tree1)
p <- p %<+% sample_name

# Change horizontal coordinates: past = negative Ma; present = zero.
# Use tip depth rather than a rounded age so tips line up at approximately 0.
tree_height <- mean(p$data$x[p$data$isTip])
p$data$x <- p$data$x - tree_height

# Use the original sample ID if a renamed label is missing.
p$data <- p$data %>%
  mutate(
    Newlabel = ifelse(is.na(Newlabel), label, Newlabel),
    Section = ifelse(is.na(Section) & isTip, str_sub(label, 1, 1), Section)
  )

# Add the vertical plotting position for each dated node.
node_ages <- left_join(ages, p$data[, c("node", "y")], by = "node")
node_ages <- node_ages %>%
  mutate(
    age_label = sprintf("%.2f", age),
    x_low = -HPD_upper,
    x_high = -HPD_lower
  )

# 5. Draw HPD bars, colored tip labels, and node ages.
# These bars are placed at their actual age endpoints, not centered arbitrarily.
p <- p +
  geom_segment(data = node_ages,
               aes(x = x_low, xend = x_high, y = y, yend = y),
               inherit.aes = FALSE, color = "#3182BD",
               linewidth = 2.5, alpha = 0.35) +
  geom_tiplab(aes(label = Newlabel, color = Section),
              size = 3.5, offset = 0.08, show.legend = FALSE) +
  scale_color_manual(values = c("C" = "#D55E00",
                               "G" = "#0072B2",
                               "K" = "#009E73",
                               "D" = "#CC79A7")) +
  geom_text(data = node_ages,
            aes(x = -age, y = y, label = age_label),
            inherit.aes = FALSE, size = 2.3,
            vjust = -0.6, hjust = 1, color = "black") +
  theme_tree2() +
  scale_x_continuous(breaks = seq(-10, 0, 1),
                     labels = function(x) abs(x), limits = c(-10.5, 4)) +
  xlab("Age before present (Ma)")
p

# If recent-node age labels overlap, show only backbone-node labels instead:
# node_ages <- subset(node_ages, lengths(strsplit(descendant_tips, ";")) >= 25)
# Put that line BEFORE section 5, then rerun section 5 from a fresh p in section 4.

# 6. Save the figure. PDF text remains editable in Illustrator.
ggsave("Cotton_MCMCtree_ages.pdf", plot = p, width = 12, height = 10)
ggsave("Cotton_MCMCtree_ages.png", plot = p, width = 12, height = 10, dpi = 300)
ggsave("Cotton_MCMCtree_ages.tif", plot = p, width = 12, height = 10,
       dpi = 300, compression = "lzw")

# These labels use the ages represented by the FigTree branch lengths / CSV.
# They should not be described as posterior means without checking the summary.
# The 5-10 Ma root calibration is soft, so HPD limits may extend outside it.
