# Group means and plotting filters follow f3f4plot.R; count distinct k-mers by row weight.
library(tidyverse)
x <- read.table("n38_30mer.intersections", header = TRUE, sep = "", check.names = FALSE)
labels <- read.delim("../03_astraltree/rename_ntDNA.txt", check.names = FALSE)
stopifnot(!anyDuplicated(labels$Label), all(c("Number_of_kmers", "fasta_File") %in% names(x)))
rename_map <- setNames(labels$Newlabel, labels$Label)
hit <- names(x) %in% names(rename_map)
names(x)[hit] <- unname(rename_map[names(x)[hit]])
sample_cols <- setdiff(names(x), c("Number_of_kmers", "fasta_File"))
group <- sub("^([A-Za-z]+[0-9]+).*", "\\1", sample_cols)
group[grepl("^K[0-9]+_", sample_cols)] <- "K"
groups <- c("C1", "C2", "G1", "G2", "G3", "K")
stopifnot(setequal(unique(group), groups), !anyDuplicated(x$fasta_File),
          all(is.finite(x$Number_of_kmers)), all(x$Number_of_kmers >= 0))
for (g in groups) {
  m <- as.matrix(x[, sample_cols[group == g], drop = FALSE])
  stopifnot(is.numeric(m), all(is.finite(m)))
  x[[g]] <- rowMeans(m)
  x[[g]][x[[g]] < 1] <- 0
}
result <- x %>% select(Number_of_kmers, fasta_File, all_of(groups))
write.csv(result, "kmer_group_means.csv", row.names = FALSE)
binary <- as.matrix(result[, groups]) > 0
n_present <- rowSums(binary)
keep <- n_present > 1 & n_present < length(groups) & rowSums(result[, groups]) >= 10
plot_rows <- result[keep, ]
# Counts below use the full thresholded table, not only rows retained for plotting.
count_shared <- function(targets, exclusive = FALSE) {
  included <- rowSums(binary[, targets, drop = FALSE]) == length(targets)
  other <- setdiff(groups, targets)
  if (exclusive && length(other)) included <- included & rowSums(binary[, other, drop = FALSE]) == 0
  tibble(groups = paste(targets, collapse = "+"), exclusive = exclusive,
         distinct_kmers = sum(result$Number_of_kmers[included]),
         distinct_kmers_in_plot = sum(result$Number_of_kmers[included & keep]))
}
pair_counts <- map_dfr(combn(groups, 2, simplify = FALSE), function(g) count_shared(g, TRUE))
write.csv(pair_counts, "exclusive_pair_counts.csv", row.names = FALSE)
checks <- bind_rows(count_shared(c("G1", "G2", "G3")), count_shared(c("G2", "G3"), TRUE),
                    count_shared(c("C1", "C2", "G2")))
print(checks)
write.csv(checks, "selected_shared_counts.csv", row.names = FALSE)
# Unique row IDs avoid collisions if different intersections have the same number of k-mers.
plot_rows$Sample <- paste(plot_rows$Number_of_kmers, plot_rows$fasta_File, sep = "_")
levels <- plot_rows$Sample
if (nrow(plot_rows) > 1) levels <- levels[hclust(dist(as.matrix(plot_rows[, groups]) > 0, method = "binary"), method = "average")$order]
long <- plot_rows %>% pivot_longer(all_of(groups), names_to = "Group", values_to = "Value") %>%
  mutate(Sample = factor(Sample, levels = levels), Group = factor(Group, levels = rev(groups)),
         Category = factor(case_when(Value < 10 ~ "<10", Value < 20 ~ "10-20",
                           Value < 30 ~ "20-30", TRUE ~ "30+"), levels = c("<10", "10-20", "20-30", "30+")))
plot_kmers <- function(d) ggplot(filter(d, Value > 0), aes(Sample, Group)) +
  geom_point(aes(size = Category, color = Category)) +
  scale_size_manual(values = c("<10" = 1, "10-20" = 2, "20-30" = 3, "30+" = 4), drop = FALSE) +
  scale_color_manual(values = c("<10" = "#E69F00", "10-20" = "#56B4E9", "20-30" = "#009E73", "30+" = "#D55E00"), drop = FALSE) +
  theme_minimal() + theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 5),
    panel.grid.major.y = element_blank(), panel.grid.minor = element_blank()) + labs(x = NULL, y = "Group")
p_kmer <- plot_kmers(long)
ggsave("kmer_overlap_all.pdf", p_kmer, width = 14, height = 5, useDingbats = FALSE)
pair_long <- long %>% filter(as.character(Sample) %in% plot_rows$Sample[n_present[keep] == 2]) %>%
  mutate(Sample = droplevels(Sample))
ggsave("kmer_overlap_pairs.pdf", plot_kmers(pair_long), width = 10, height = 4, useDingbats = FALSE)
