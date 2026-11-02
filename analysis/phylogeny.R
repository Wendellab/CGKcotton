# Adapted from 03_astraltree/ASTRALtree.R; original preserved in source_archive/Ozcotton/.
# Run through scripts/run_analysis.R from the repository root.
setwd(cgk_work_dir)

library("patchwork")     
library("png")
library(ggtree)
library(treeio)
library(tidytree)
library(dplyr)
library(ggplot2)
library(aplot)
library(ggtreeExtra)
library(ggnewscale)
library(reshape2)
library(phangorn)
library(ggpubr)
library(ggimage)


DCGKtree <- read.tree(file = "n18784_filter_trees_bs03_rt_astral_rt.tre")
ozname <- read.csv("rename_ntDNA.txt", sep = "\t")


tree1 = full_join(as_tibble(DCGKtree), ozname, by = c('label' = 'Label')) %>%
  as.treedata()


p <- ggtree(tree1) +  
  geom_tiplab(aes(label= Newlabel, color = Section), size =4, offset = 0.2, show.legend=FALSE) + 
  geom_nodelab(size = 3, nudge_x = 0.7, color = 'red')  +
  geom_rootedge(rootedge = 1)  + 
  scale_color_manual(values=c("C"= "#D55E00",
                              "G"= "#0072B2",
                              "K"= "#009E73",
                              "D" = "#CC79A7")) +
  hexpand(0.3)
p

#############################################################

k <- read.table("DCGK_n18784.node.key", header=F, row.names=NULL, sep=" ", na.strings = c("", "NA"), stringsAsFactors=FALSE)

colnames(k) <- c("NodeP", "Tips")
NodeP <- rep(0, length(k$NodeP))
k2 <- as.data.frame(NodeP)
k2$NodeT <- rep(0, length(k2$NodeP))

for (x in 1:length(k[,1])) {
  k2$NodeP[x] <-  k[x,1]
  tips <- gsub("\\)|\\(", ",", k[x,2])
  tips_vec <- strsplit(tips, ",")
  tips_vec2 <- grep("^[CDGK]", tips_vec[[1]], value = TRUE)
  k2$NodeT[x] <- mrca.phylo(DCGKtree, tips_vec2)
}


phypart_pie <- read.table(file = "phyparts_pies.csv", sep = ",", header = T)
new_pie <- cbind(k2, phypart_pie)[c(2,4:7)]
names(new_pie)[names(new_pie) == 'NodeT'] <- 'node'



library(scatterpie)

pie.df <- merge( p$data[, c("node","x","y")], new_pie,  by = "node")

p1 <- p + geom_scatterpie(data = pie.df, aes(x, y, r = 0.5),
                          cols = c("adj_concord","adj_most_conflict","other_conflict","the_rest"),
                          pie_scale = 1, alpha = 0.8, color = NA) +
  scale_fill_manual(breaks = c("adj_concord","adj_most_conflict","other_conflict","the_rest"),
                    values = c(adj_concord="#56B4E9", adj_most_conflict="#009E73",
                               other_conflict="#CC79A7", the_rest="grey"),
                    labels = c(adj_concord="Concordant",
                               adj_most_conflict="Top alternative",
                               other_conflict="Other alternative ",
                               the_rest="Uninformative")) +
  theme(legend.position = c(0.1, 0.8)) + coord_fixed()+
  geom_treescale(x = 0, y = 0, width = 1, fontsize = 3)

p1

#########################################################################

DCGKcpTree <- read.tree(file = "changed_n42_IRB_aln_noIRB_nogap_rt.treefile")
ozname <- read.csv("rename_cpDNA.txt", sep = "\t")

tree2 = full_join(as_tibble(DCGKcpTree), ozname, by = c('label' = 'Label')) %>%
  as.treedata()

tree2.nodes <- subset(as_tibble(tree2), as.numeric(label) >= 100)$node 

p2 <- ggtree(tree2) +
  geom_tiplab(aes(label= Newlabel, color = Section), nudge_x = -0.0025, size =4,show.legend=FALSE) +
  geom_point2(aes(subset=(node %in% tree2.nodes)),color="black",size=1.5) +
  geom_rootedge(rootedge = 0.0001) + 
  scale_color_manual(values=c("C"= "#D55E00",
                              "G"= "#0072B2",
                              "K"= "#009E73",
                              "D" = "#CC79A7")) +
  hexpand(0.2)+
  geom_treescale(x = -0.001, y = 0, width = 0.001, fontsize = 3)

p2 <- p2 + scale_x_reverse()
p2

#########################################################################
#########################################################################

DCGKcpTree_geneonly <- read.tree(file = "cpDNA_supermatrix_nogap_rt.treefile")
ozname <- read.csv("rename_cpDNA.txt", sep = "\t")

tree3 = full_join(as_tibble(DCGKcpTree_geneonly), ozname, by = c('label' = 'Label')) %>%
  as.treedata()

tree3.nodes <- subset(as_tibble(tree3), as.numeric(label) >= 100)$node 

p3 <- ggtree(tree3) +
  geom_tiplab(aes(label= Newlabel, color = Section), nudge_x = 0.0001, size =4,show.legend=FALSE) +
  geom_point2(aes(subset=(node %in% tree3.nodes)),color="black",size=1.5) +
  geom_text2(aes(subset = !isTip, label = label),
             hjust = -0.3, size = 2) +
  geom_rootedge(rootedge = 0.0001) + 
  scale_color_manual(values=c("C"= "#D55E00",
                              "G"= "#0072B2",
                              "K"= "#009E73",
                              "D" = "#CC79A7")) +
  hexpand(0.5)

p3

##############################################################

library(gridExtra)

pdf("Fig5_nuclear_plastome.pdf", width = 14, height = 10)
grid.arrange( p1, p2, ncol=2)
dev.off()

pdf("plastome_CDS_tree.pdf", width = 8, height = 8)
print(p3)
dev.off()
