library(tidyverse)
stats <- read.delim("n19028_all_trees_stat.txt", check.names = FALSE)
ids <- readLines("n18784_gene_list.csv", warn = FALSE)
stats$gene_id <- sub("^DCGK_(.+)_aln_trim[.]fasta$", "\\1", stats$Alignment_name)
stopifnot(!anyDuplicated(ids), !anyDuplicated(stats$gene_id))
retained <- stats %>% filter(gene_id %in% ids)
stopifnot(nrow(retained) == length(ids), nrow(retained) == 18784)
summary <- retained %>% summarise(loci = n(), mean_length = mean(Alignment_length),
  total_PIS = sum(Parsimony_informative_sites), mean_PIS = mean(Parsimony_informative_sites))
print(summary)
write.csv(summary, "alignment_summary.csv", row.names = FALSE)
write.csv(retained, "retained_alignment_statistics.csv", row.names = FALSE)
p <- retained %>% select(Alignment_length, Parsimony_informative_sites) %>%
  pivot_longer(everything(), names_to = "metric", values_to = "value") %>%
  ggplot(aes(metric, value, fill = metric)) + geom_violin(alpha = 0.35, trim = FALSE, color = NA) +
  geom_boxplot(width = 0.12, alpha = 0.7, outlier.size = 0.8) +
  scale_x_discrete(labels = c(Alignment_length = "Alignment length (bp)",
    Parsimony_informative_sites = "Parsimony-informative sites")) +
  scale_y_log10() + labs(x = NULL, y = NULL) + theme_classic(base_size = 12) + theme(legend.position = "none")
ggsave("alignment_statistics.pdf", p, width = 10, height = 5)
