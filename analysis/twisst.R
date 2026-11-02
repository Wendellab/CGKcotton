# Adapted from 04_KmerCity/Twisst_f3_Kmer.R; original preserved in source_archive/Ozcotton/.
# Run through scripts/run_analysis.R from the repository root.
library(ape)
library(ggtree)
library(ggplot2)
library(patchwork)

cols <- c(C="#D55E00", G="#0072B2", G1="#0072B2", G2G3="#0072B2",K="#009E73", D5="#CC79A7")

trees <- list(
  T7=read.tree(text="(D5,((C,G),K));"),
  T8=read.tree(text="(D5,((C,K),G));"),
  T9=read.tree(text="(D5,(C,(G,K)));"),
  
  T1=read.tree(text="(D5,((C,G1),K));"),
  T2=read.tree(text="(D5,((C,K),G1));"),
  T3=read.tree(text="(D5,(C,(G1,K)));"),
  
  T4=read.tree(text="(D5,((C,G2G3),K));"),
  T5=read.tree(text="(D5,((C,K),G2G3));"),
  T6=read.tree(text="(D5,(C,(G2G3,K)));")
)

tree_plot <- function(tree) {
  dat <- data.frame(label=tree$tip.label, group=tree$tip.label)
  ggtree(tree, branch.length="none", size=2, layout="slanted") %<+% dat +
    geom_tree(aes(color=group), size=2,layout="slanted") +
    geom_tiplab(aes(color=group), size=5, offset=1) +
    scale_color_manual(values=cols, na.value="grey35") +
    theme_tree() +
    theme(legend.position="none", plot.margin=margin(2,2,2,2))+
    xlim(0, 10)
}

tree_row <-    tree_plot(trees$T7) | tree_plot(trees$T8) | tree_plot(trees$T9) |
  tree_plot(trees$T4) | tree_plot(trees$T5) | tree_plot(trees$T6) |
  tree_plot(trees$T1) | tree_plot(trees$T2) | tree_plot(trees$T3) 

tree_row

# Recorded draft percentages, not new inference; see AUTHOR_REVIEW.md for their sum.
weights <- data.frame(Group = rep(c("G", "G2/G3", "G1"), each = 3),
 Topology = rep(c("T1", "T2", "T3"), 3),
 Weight = c(36.1, 25.4, 38.5, 38.6, 24.1, 37.7, 33.9, 26.2, 40.0))

bar_plot <- function(group) {
  ggplot(subset(weights,Group==group),aes(Topology,Weight)) +
    geom_col(width=0.5,fill="#0072B2") +
    geom_text(aes(label=paste0(Weight,"%")),vjust=-0.3,size=5) +
    scale_y_continuous(limits=c(0,45),expand=expansion(mult=c(0,.03))) +
    labs(title=group,y="Topology weight (%)",x=NULL) +
    theme_classic(base_size=10) +
    theme(plot.title=element_text(vjust=-0.5),
          axis.text.x=element_text(size=14))
}

bar_row <- bar_plot("G") | bar_plot("G2/G3") | bar_plot("G1")

final_plot <- tree_row / bar_row + plot_layout(heights=c(1,1))
final_plot

ggsave("Twisst_topology_figure.pdf",final_plot,width=12,height=5.5)
ggsave("Twisst_topology_figure.png",final_plot,width=12,height=5.5,dpi=600)

