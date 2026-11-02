# Adapted from 05_mappingrate/mappingrate_plot.R; original source files retained outside this repository.
# Run through 99_Supplemental/scripts/run_analysis.R from the repository root.
setwd(cgk_work_dir)

library(tidyr)
library(ggplot2)
library(dplyr)

df <- read.delim("mappingratecomparison.tsv")

df$group <- case_when(
  grepl("^C1", df$sample) ~ "C1",
  grepl("^C2", df$sample) ~ "C2",
  grepl("^K", df$sample) ~ "K",
  grepl("^G1", df$sample) ~ "G1",
  grepl("^G2", df$sample) ~ "G2",
  grepl("^G3", df$sample) ~ "G3",
  grepl("^D5", df$sample) ~ "D",
  TRUE ~ NA_character_)


df_range <- df %>%
  group_by(group, reference) %>%
  summarise(
    Mean = round(mean(properly_paired_pct), 2),
    Range = paste0(
      round(min(properly_paired_pct), 2),
      "-",
      round(max(properly_paired_pct), 2)
    ),
    .groups = "drop"
  )

write.csv(df_range, "mapping_range_table.csv", row.names = FALSE, quote = FALSE)


df$group <- factor(df$group,
                   levels = c("C1","C2", "G1", "G2", "G3", "K", "D"))

df_long <- pivot_longer(
  df,
  cols = c(mapped_pct, properly_paired_pct),
  names_to = "metric",
  values_to = "value")

df_long$metric <- factor(df_long$metric,
                         levels = c("mapped_pct", "properly_paired_pct"),
                         labels = c("Primary mapped (%)", "Properly paired (%)"))

df_long$reference <- gsub("reference", "", df_long$reference)

species_labels <- c(
  "C1" = expression(atop(italic("G. sturtianum"), "(C1)")),
  "C2" = expression(atop(italic("G. robinsonii"), "(C2)")),
  "G1" = expression(atop(italic("G. bickii"), "(G1)")),
  "G2" = expression(atop(italic("G. australe"), "(G2)")),
  "G3" = expression(atop(italic("G. nelsonii"), "(G3)")),
  "K"  = expression(atop(paste("sect.", italic("Grandicalyx")), "(K genome)")),
  "D"  = expression(atop(italic("G. raimondii"), "(D5)"))
)
p <- ggplot(df_long, aes(x = group,
                    y = value,
                    fill = reference)) +
  geom_boxplot(width = 0.8, alpha = 0.8, linewidth = 0.4, outlier.alpha = 0.2) +
  facet_wrap(~metric, nrow = 1, scales = "fixed") +
  scale_fill_brewer(palette = "Set2") +
  scale_x_discrete(labels = species_labels) +
  theme_bw() +
  labs(x = NULL,
       y = "Mapping rate (%)",
       fill = "Reference") +
  theme(
    strip.background = element_blank(),
    strip.text = element_text(size = 12),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 12)  )

p

ggsave("Fig3_mapping_bias.pdf",
       plot = p,
       width = 16,
       height = 5,
       device = "pdf")



library(dplyr)
library(tidyr)

# ---- 1. clean + prepare ----
df_clean <- df_long %>%
  mutate(
    reference = gsub("_HAU|_CRI|reference", "", reference)
  )

# ---- 2. pivot BOTH metrics to wide ----
df_wide <- df_clean %>%
  select(sample, reference, metric, value) %>%
  pivot_wider(names_from = c(reference, metric),
              values_from = value)

write.csv(df_wide, "mapping_wide_table.csv", row.names = FALSE, quote = FALSE)
