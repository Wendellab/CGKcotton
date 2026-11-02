# Adapted from 00_Distribution/DistributionofKgroup.R; original preserved in source_archive/Ozcotton/.
# Run through scripts/run_analysis.R from the repository root.
library(tidyverse)
library(sf)
library(rnaturalearth)
library(patchwork)
library(ggtext)

data_dir <- cgk_work_dir
dat <- read_tsv(file.path(data_dir, "Ozcotton_1970to2025_NativeOnly.txt"), show_col_types = FALSE) %>%
  mutate(across(c(decimalLongitude, decimalLatitude), as.numeric))
x_limits <- c(121.7, 129)
y_limits <- c(-18.2, -13.35)

key <- tribble(
  ~specificEpithet, ~Genome, ~Clade,
  "costulatum", "K8", "Clade1",
  "anapoides", "K12", "Clade1",
  "pulchellum", "K10", "Clade1",
  "marchantii", "K5", "Clade1",
  "pilosum", "K4", "Clade1",
  "cunninghamii", "K9", "Clade1",
  "nobile", "K11", "Clade2",
  "londonderriense", "K6", "Clade2",
  "enthyle", "K7", "Clade2",
  "exiguum", "K1", "Clade2",
  "rotundifolium", "K2", "Clade2",
  "populifolium", "K3", "Clade2"
) %>% mutate(Species = paste0("G. ", specificEpithet, " (", Genome, ")"))

# Detailed boundaries
cache <- file.path(data_dir, "Australian_states_10m.rds")
if (!file.exists(cache)) {
  states <- ne_download(scale = 10, type = "admin_1_states_provinces",
                        category = "cultural", returnclass = "sf") %>%
    filter(admin == "Australia") %>% st_transform(4326) %>% st_make_valid()
  saveRDS(states, cache)
}
states <- readRDS(cache)
wa <- filter(states, name == "Western Australia")

# Main-map records
occ <- dat %>% inner_join(key, by = "specificEpithet") %>%
  filter(Genome != "K9",
         between(decimalLongitude, x_limits[1], x_limits[2]),
         between(decimalLatitude, y_limits[1], y_limits[2])) %>%
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326, remove = FALSE)
inside <- lengths(st_intersects(st_transform(occ, 3577), st_transform(wa, 3577))) > 0
occ <- st_drop_geometry(occ[inside, ])
points <- distinct(occ, Species, decimalLongitude, decimalLatitude, .keep_all = TRUE)

# K9 inset records
k9 <- dat %>% inner_join(filter(key, Genome == "K9"), by = "specificEpithet") %>%
  filter(is.finite(decimalLongitude), is.finite(decimalLatitude),
         between(decimalLongitude, -180, 180), between(decimalLatitude, -90, 90))
stopifnot(nrow(k9) > 0)
k9_points <- distinct(k9, decimalLongitude, decimalLatitude)
k9_xlim <- range(k9$decimalLongitude) + c(-0.15, 0.15)
k9_ylim <- range(k9$decimalLatitude) + c(-0.15, 0.15)

counts <- bind_rows(occ, k9) %>% count(Species, specificEpithet, Genome)
legend_labels <- setNames(
  paste0("<i>G. ", counts$specificEpithet, "</i> (", counts$Genome, "); n = ", counts$n),
  counts$Species
)
colors <- setNames(c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#882255",
                     "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#333333"), key$Species)
shapes <- setNames(c(16, 17, 15, 18, 8, 17, 16, 17, 15, 18, 8, 3), key$Species)

# Transparent K9 inset
k9_map <- ggplot() +
  geom_sf(data = states, fill = "#F0E6D2", color = "grey45", linewidth = 0.2, alpha = 0.5) +
  geom_point(data = k9_points, aes(decimalLongitude, decimalLatitude),
             color = "#882255", shape = 17, size = 1.6, alpha = 0.7) +
  annotate("text", x = k9_xlim[2] - 0.3, y = k9_ylim[2] - 0.22, label = "K9", size = 3) +
  scale_x_continuous(breaks = k9_xlim, labels = function(x) sprintf("%.2f", x)) +
  scale_y_continuous(breaks = k9_ylim, labels = function(y) sprintf("%.2f", y)) +
  coord_sf(xlim = k9_xlim, ylim = k9_ylim, default_crs = st_crs(4326), expand = FALSE) +
  labs(x = NULL, y = NULL) +
  theme_bw(base_size = 7) +
  theme(panel.background = element_rect(fill = "transparent", color = NA),
        panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, color = "grey40", linewidth = 0.4),
        axis.text = element_text(size = 7, color = "black"),
        axis.ticks = element_line(linewidth = 0.25),
        plot.background = element_rect(fill = "transparent", color = NA),
        plot.margin = margin(2, 5, 1, 1))

make_map <- function(clade) {
  sp <- key %>% filter(Clade == clade, Species %in% counts$Species) %>% pull(Species)
  map_points <- filter(points, Clade == clade)
  note <- NULL
  if (clade == "Clade1") {
    map_points <- bind_rows(map_points, tibble(
      Species = "G. cunninghamii (K9)", decimalLongitude = NA_real_, decimalLatitude = NA_real_
    ))
    note <- "<i>G. pilosum</i> (K4) placed here for display only; genetic data unavailable."
  }
  
  ggplot() +
    geom_sf(data = states, fill = "#F0E6D2", color = "grey50", linewidth = 0.25) +
    geom_sf(data = wa, fill = "#E2ECD5", color = "grey40", linewidth = 0.25) +
    geom_point(data = map_points,
               aes(decimalLongitude, decimalLatitude, color = Species, shape = Species),
               size = 2.7, alpha = 0.9, na.rm = TRUE, show.legend = TRUE) +
    scale_color_manual(clade, values = colors, limits = sp, labels = unname(legend_labels[sp])) +
    scale_shape_manual(clade, values = shapes, limits = sp, labels = unname(legend_labels[sp])) +
    scale_x_continuous(breaks = 122:129, labels = function(x) sprintf("%.1f", x)) +
    scale_y_continuous(breaks = seq(-18, -13.5, 0.5), labels = function(y) sprintf("%.1f", y)) +
    coord_sf(xlim = x_limits, ylim = y_limits, default_crs = st_crs(4326), expand = FALSE) +
    labs(subtitle = note, x = "Longitude", y = "Latitude") +
    theme_bw(base_size = 11) +
    theme(panel.background = element_rect(fill = "#DDEEF5", color = NA),
          panel.grid.major = element_line(color = "white", linewidth = 0.25),
          plot.background = element_rect(fill = "transparent", color = NA),
          plot.subtitle = element_markdown(size = 9),
          plot.margin = margin(2, 2, 2, 2),
          legend.position = "right",
          legend.title = element_text(size = 12),
          legend.text = element_markdown(size = 9),
          legend.background = element_rect(fill = "transparent", color = NA),
          legend.box.background = element_rect(fill = "transparent", color = NA),
          legend.key = element_rect(fill = "transparent", color = NA),
          legend.margin = margin(0, 0, 0, 0),
          legend.box.spacing = grid::unit(0.15, "cm"),
          legend.key.height = grid::unit(0.6, "cm"))
}

p1 <- make_map("Clade1") +
  inset_element(k9_map,
                left = (122.1 - x_limits[1]) / diff(x_limits),
                right = (124.25 - x_limits[1]) / diff(x_limits),
                bottom = (-15.65 - y_limits[1]) / diff(y_limits),
                top = (-13.35 - y_limits[1]) / diff(y_limits),
                align_to = "panel")
p <- (p1 / make_map("Clade2")) +
  plot_annotation(theme = theme(
    plot.background = element_rect(fill = "transparent", color = NA),
    plot.margin = margin(0, 0, 0, 0)
  ))
print(p)
ggsave(file.path(data_dir, "clade_distribution_WA_K4.pdf"), p,
       width = 10, height = 10.8, bg = "transparent", useDingbats = FALSE)
