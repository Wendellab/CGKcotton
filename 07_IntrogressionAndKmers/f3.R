library(admixtools)
library(tidyverse)
saved <- new.env()
load("CGK.RData", envir = saved)
stopifnot(exists("f2_blocks", envir = saved, inherits = FALSE))
f2_blocks <- saved$f2_blocks
f3_results <- as.data.frame(admixtools::f3(f2_blocks))
stopifnot(all(c("pop1", "pop2", "pop3", "est", "se", "z") %in% names(f3_results)))
f3_results <- f3_results %>% arrange(pop1, est) %>% mutate(source_pair = paste(pop2, pop3, sep = ", "),
  significant = z < -3, label = paste0(source_pair, ifelse(significant, " **", "")), y_pos = row_number())
write.csv(f3_results, "f3_results_recomputed.csv", row.names = FALSE)
print(filter(f3_results, significant))
p <- ggplot(f3_results, aes(est, y_pos)) + geom_point(color = "#D55E00", size = 2) +
  geom_segment(aes(x = est - se, xend = est + se, yend = y_pos), color = "#D55E00") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_y_continuous(breaks = f3_results$y_pos, labels = paste(f3_results$pop1, f3_results$label, sep = ": ")) +
  labs(x = "f3(target; source 1, source 2), +/- 1 SE", y = NULL) + theme_classic(base_size = 9)
ggsave("f3_all_trios.pdf", p, width = 10, height = max(6, 0.12 * nrow(f3_results)), limitsize = FALSE)
