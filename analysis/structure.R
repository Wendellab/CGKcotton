# Adapted from 04_KmerCity/SNPsOzcotton/SNPplot.R; original preserved in source_archive/Ozcotton/.
# Run through scripts/run_analysis.R from the repository root.
setwd(cgk_work_dir)
library(ggplot2)
library(dplyr)
library(ggtree)
library(treeio)
library(tidyverse)
library(ggrepel)
library(RColorBrewer)
library(ggtreeExtra)
library(ggnewscale)


################################################################
LEAcolor <- c("#000000", "#E69F00", "#56B4E9", "#009E73",  "#0072B2", "#D55E00", "#CC79A7")
imiss <- read.table("missing_individual.imiss",
                    header = TRUE, stringsAsFactors = FALSE)
ozname <- read.csv(file.path(cgk_work_root, "03_astraltree/rename_ntDNA.txt"), sep = "\t")
imiss <- left_join(imiss, ozname, by = c("INDV" = "Label"))
imiss$SUBGROUP <- ifelse(grepl("^K[0-9]+", imiss$Group), "K",
                         imiss$Group)


# order x-axis nicely
imiss$SUBGROUP <- factor(imiss$SUBGROUP,
                         levels = c("C1","C2","G1","G2","G3","K", "D5"))

# n labels per subgroup
n_labels <- imiss %>%
  group_by(SUBGROUP) %>%
  summarise(
    n = n(),
    y = max(F_MISS, na.rm = TRUE) * 1.05,
    .groups = "drop"
  )

label_df <- imiss %>%
  filter(SUBGROUP %in% c("C2", "D5"), F_MISS > 0.1)

# plot
p <- ggplot(imiss, aes(x = SUBGROUP, y = F_MISS, fill = Section)) +
  geom_boxplot(width = 0.5, outlier.size = 1, alpha = 0.75) +
  geom_jitter(color = "black", width = 0.15, alpha = 0.9, size = 2) +
  geom_text(data = n_labels, aes(x = SUBGROUP, y = y + 0.02, label = paste0("n=", n)),
            inherit.aes = FALSE,  size = 4) +
  geom_text_repel(data=label_df, aes(SUBGROUP,F_MISS,label=INDV),
                  inherit.aes=FALSE, size=4, segment.color="grey50",
                  box.padding=0.3, point.padding=0.2) +
  labs( y = "Missing Rate (F_MISS)", fill = "Group (CGK)" ) +
  scale_fill_manual(values=c("C"= "#D55E00",
                              "G"= "#0072B2",
                              "K"= "#009E73",
                              "D" = "#CC79A7")) +

  theme_classic() +  
  theme(axis.title.x = element_blank(),
        legend.position = c(0.1, 0.85),
        legend.background = element_rect(fill = "white",color = "black",  linewidth = 0.6))

p
##########################################a##########


pca <- read_table(list.files(pattern="\\.eigenvec$"), col_names=FALSE)
eigenval <- scan(list.files(pattern="\\.eigenval$"))
ozname <- read.csv(file.path(cgk_work_root, "03_astraltree/rename_ntDNA.txt"), sep = "\t")

pca <- pca[, -1]

names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC",1:(ncol(pca)-1))
pca <- left_join(pca, ozname, by = c("ind" = "Label"))
pca$SUBGROUP <- ifelse(grepl("^K[0-9]+", pca$Group), "K",
                       pca$Group)


pve <- data.frame(PC=1:length(eigenval), pve=eigenval/sum(eigenval)*100)

# pca$population <- sub("^([A-Za-z]+[0-9]+).*","\\1", pca$ind)
# 
# pca$group <- case_when(
#   grepl("^C1",pca$population)~"C1",
#   grepl("^C2",pca$population)~"C2",
#   grepl("^G1",pca$population)~"G1",
#   grepl("^G2",pca$population)~"G2",
#   grepl("^G3",pca$population)~"G3",
#   grepl("^K",pca$population)~"K",
#   TRUE~"Other"
# )

b <- ggplot(pca,aes(PC1,PC2,color=SUBGROUP, shape = SUBGROUP)) +
  geom_point(size=4,alpha=0.9) +
 # geom_text_repel(aes(label=Newlabel),size=2.5,max.overlaps=Inf,segment.color="grey50",segment.size=0.3, show.legend = F) +
  geom_text_repel(data=subset(pca, Newlabel==Sys.getenv("CGK_LABEL_SAMPLE", "")),aes(label=Newlabel),size=4,max.overlaps=Inf,segment.color="grey50",segment.size=0.3,show.legend=F) +
  xlab(paste0("PC1 (",round(pve$pve[1],2),"%)")) +
  ylab(paste0("PC2 (",round(pve$pve[2],2),"%)")) +
  labs(color = "Group", shape = "Group")+
  scale_color_manual(values=c(
    C1="#D55E00",
    C2="#D55E00",
    G1="#0072B2",
    G2="#0072B2",
    G3="#0072B2",
    K="#009E73"
  )) +
  theme_classic() + 
  theme(legend.position = c(0.1, 0.8),
        legend.background = element_rect(fill = "white",color = "black",  linewidth = 0.6))

b



##########################################################

LEAcolor <- c("#CC79A7", "#009E73", "#D55E00", "#0072B2")

CGK_astral <- read.tree("n18784_filter_trees_bs03_rt_astral_rt.tre")
CGK_astral_rename = full_join(as_tibble(CGK_astral), ozname, by = c('label' = 'Label')) %>%
  as.treedata()


CGK_astral_tre <- ggtree(CGK_astral_rename) +
  geom_tiplab(aes(label=Newlabel, color = Section), align=TRUE, offset=0.005, size=4, show.legend=FALSE) +
  geom_rootedge(rootedge=0.2, linewidth=0.9)+
  xlim(-1,35) + 
  scale_color_manual(values=c("C"= "#D55E00",
                              "G"= "#0072B2",
                              "K"= "#009E73",
                              "D" = "#CC79A7")) 

CGK_astral_tre

lea_saved <- new.env()
load("LEAstruture_n65.RData", envir = lea_saved)
stopifnot(exists("plot_list", envir = lea_saved, inherits = FALSE))
colplot <- lea_saved$plot_list[[4]]$data
colplot$individual <- as.character(colplot$individual)


CGKtree <- CGK_astral_tre + new_scale_fill() +
  geom_fruit(data=colplot, geom=geom_col,
             mapping=aes(y=individual, x=q, fill=pop),
             axis.params=list(axis="x", text="M", text.size=3, limits=c(0,1.1)),
             offset=0.77, pwidth=0.5) +
  scale_fill_manual(values=LEAcolor) +
  theme(legend.position="none",
        panel.spacing.x=unit(0,"lines"),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.title=element_blank(),
        panel.grid=element_blank(),
        panel.background=element_blank(),
        strip.background=element_blank()
  )

CGKtree

##########################################################

library(cowplot)

finalplot <- ggdraw() +
  draw_plot(p, x = 0,    y = 0.5, width = 1/2, height = 0.5) +
  draw_plot(b, x = 0,    y = 0,   width = 1/2, height = 0.5) +
  draw_plot(CGKtree, x = 1/2, y = 0, width = 1/2, height = 1) +
  draw_plot_label(
    label = c("a","b","c"),
    x = c(0, 0, 0.5),
    y = c(1, 0.5, 1),
    size = 16,
    fontface = "bold"
  )

finalplot
##########################################################

ggsave("Fig6_missing_PCA_LEA.pdf", plot=finalplot, width=15, height=10)


# Saved table contains the selected run for each K, not all ten replicate scores.
ce <- lea_saved$kvalue
p_ce <- ggplot(ce, aes(K, cross.entropy)) + geom_line() + geom_point() +
  scale_x_continuous(breaks = ce$K) + labs(y = "Cross entropy", x = "K") + theme_classic()
ggsave("LEA_cross_entropy.pdf", p_ce, width = 6, height = 4)
