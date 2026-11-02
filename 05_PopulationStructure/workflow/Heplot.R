library(tidyverse)

het <- read.table("CGK_nomissing.het", header = TRUE)

het$Group <- case_when(
  grepl("^C1", het$INDV) ~ "C1",
  grepl("^C2", het$INDV) ~ "C2",
  grepl("^G1", het$INDV) ~ "G1",
  grepl("^G2", het$INDV) ~ "G2",
  grepl("^G3", het$INDV) ~ "G3",
  grepl("^K",  het$INDV) ~ "K"
)

het$Ho <- (het$N_SITES - het$O.HOM.) / het$N_SITES

p <- ggplot(het, aes(Group, Ho)) +
    geom_boxplot(width = 0.6, outlier.shape = NA) +
    geom_jitter(width = 0.15, size = 2) +
    labs(x = NULL,
         y = "Observed heterozygosity (Ho)") +
    theme_classic(base_size = 14)

ggsave("CGK.nomissing.Ho.pdf",
       p,
       width = 6,
       height = 4)