# Adapted from 00_Distribution/DistributionCotton.R; original source files retained outside this repository.
# Run through 99_Supplemental/scripts/run_analysis.R from the repository root.
setwd(cgk_work_dir)
library(ozmaps)   
library(sf)
library(ggplot2)
library(sf)
library(dplyr)
library(ggplot2)
library(grid)
library(RColorBrewer)

#install.packages("ozmaps")
#####################################################################
KozcbbPalette <- colorRampPalette(brewer.pal(n = 12, name = "Paired"))(15)
Kozcategories <- paste0("K", 1:12)
Kozcolormapping <- setNames(KozcbbPalette, Kozcategories)
Kozshape <- rep(17, 12)
Kozshapemapping <- setNames(Kozshape, Kozcategories)


#GozcbbPalette <- colorRampPalette(brewer.pal(n = 12, name = "Paired"))(3)
Gozcategories <- paste0("G", 1:3)
Gozcolormapping <- setNames(Kozcolormapping[c(1,3,6)], Gozcategories)
Gozshape <- rep(19, 3)
Gozshapemapping <- setNames(Gozshape, Gozcategories)


Cozcategories <- paste0("C", 1:2)
Cozcolormapping <- setNames(Kozcolormapping[8:9], Cozcategories)
Cozshape <- rep(15, 2)
Cozshapemapping <- setNames(Cozshape, Cozcategories)



safe_colorblind_palette <- c(Cozcolormapping,
                             Gozcolormapping,
                             Kozcolormapping)

safe_shape_palette <- c(Cozshapemapping,
                        Gozshapemapping,
                        Kozshapemapping)

#######################################################################
#######################################################################
sf_oz <- ozmap("states")

gpsoz <- read.csv("Ozcotton_1970to2025_NativeOnly.txt",sep = "\t")
cottongroup <- read.csv("cottonname.txt",sep = "\t")
gpsoz <- gpsoz %>%
  left_join(cottongroup, by = "specificEpithet") %>%
  mutate(label = paste0(GenomeGroup, " (G. ", specificEpithet, ")"))




# Create a unique mapping of GenomeGroup to your label
label_mapping <- gpsoz %>%
  select(GenomeGroup, label) %>%
  distinct() %>%
  mutate(GenomeGroup = factor(GenomeGroup,
                              levels = c("C1","C2","G1","G2","G3",
                                         "K1","K2","K3","K4","K5","K6","K7","K8","K9",
                                         "K10","K11","K12"))) %>%
  arrange(GenomeGroup)%>% 
  mutate(label = paste0(GenomeGroup, " ~ (italic('G. ", gsub(".*\\(G\\. |\\)", "", label), "'))"))


pl <- ggplot(data = sf_oz) + 
  geom_sf() +  
  coord_sf(xlim = c(112, 155),  ylim = c(-44, -10), expand = FALSE, crs = "WGS84")+
  geom_point(data = subset(gpsoz, !(GenomeGroup %in% c("G1", "G2", "G3"))), mapping = aes(x = decimalLongitude, y = decimalLatitude, color = GenomeGroup, shape = GenomeGroup),  size =3, alpha = 0.6) +
  geom_point(data = subset(gpsoz, GenomeGroup == "G2"), mapping = aes(x = decimalLongitude, y = decimalLatitude, color = GenomeGroup, shape = GenomeGroup),  size =3, alpha = 0.4) +
  geom_point(data = subset(gpsoz, GenomeGroup == "G1"), mapping = aes(x = decimalLongitude, y = decimalLatitude, color = GenomeGroup, shape = GenomeGroup),  size =3, alpha = 0.7) +
  geom_point(data = subset(gpsoz, GenomeGroup == "G3"), mapping = aes(x = decimalLongitude, y = decimalLatitude, color = GenomeGroup, shape = GenomeGroup),  size =3, alpha = 0.7) +
  scale_x_continuous(labels = scales::label_number(accuracy = 0.01)) +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.01))+
  
  scale_color_manual(values = safe_colorblind_palette,
                     breaks = label_mapping$GenomeGroup,
                     labels = parse(text = label_mapping$label),
                     name = "Genome group") +
  
  scale_shape_manual(values = safe_shape_palette,
                     breaks = label_mapping$GenomeGroup,
                     labels = parse(text = label_mapping$label),
                     name = "Genome group")+
  guides(color = guide_legend(override.aes = list(shape = unname(safe_shape_palette))), shape = "none")+

  xlab("Longitude") + ylab("Latitude") +
  theme(panel.background = element_rect(fill = "white"),
        panel.border = element_rect(colour = "black", fill=NA, linewidth=0.1),
        panel.grid.major = element_line(color = "grey90", linetype = "dashed",  size = 0.2),
        # Legend
        legend.title = element_text(size = 14, face = "bold"),
        legend.text = element_text( size = 12),
        legend.key.size = unit(0.8, "cm"),
        legend.spacing.y = unit(0.2, "cm"))
pl

pl <- pl + 
  theme(legend.title = element_text(size = 20, face = "bold"), 
        legend.text = element_text(size = 18), 
        legend.key.size = unit(1, "cm")) +
  guides(color = guide_legend(override.aes = list(shape = unname(safe_shape_palette[as.character(label_mapping$GenomeGroup)]), size = 5, alpha = 1)), 
         shape = "none")

pl
#######################################################################

pdf("CGKcotton_map_final.pdf", width = 15, height = 10)
print(pl)
dev.off()

