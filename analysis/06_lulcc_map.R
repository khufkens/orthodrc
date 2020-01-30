# This routine generates a map of both the
# orthomosaic as well as the derived land cover
# change analysis (difference between Hansen et al. 2013 data
# and the manual classification based on the mosaic).
# Output is written to the manuscript directory for
# integration in the final manuscript. Can be run standalone.

# load libraries
library(tidyverse)
library(raster)
library(rnaturalearth)
library(sf)
library(cowplot)

# homogeneous areas
h_area <- na.omit(st_read("data/cnn/sample_locations.shp"))

# read cloud and stitch-line mask
cloud_mask <- st_read("data/maps/cloud_stitch_line_mask.shp")

# load the forest change map
forest_change <- raster(
  "data/orthomosaic/yangambi_forest_cover_difference_1958_2000.tif")

# QA values
qa <- raster(
    "data/orthomosaic/yangambi_forest_mask_qa_resampled.tif")
qa <- qa * 100 # percentages instead of fractions

# subset
forest_change_subset <- crop(forest_change,
                             extent(c(24.4356, 24.5165,
                                       0.9156,0.9839)))
# load the orthomosaic
orthomosaic <- brick("data/orthomosaic/yangambi_orthomosaic_modified_resampled.tif")
orthomosaic[orthomosaic == 255] <- NA
orthomosaic_subset <-
  crop(raster("data/orthomosaic/yangambi_orthomosaic_modified_resampled.tif"),
                           extent(c(24.4356, 24.5165,
                                    0.9156,0.9839)))

# grab subset bounding box
bb <- st_as_sfc(st_bbox(orthomosaic_subset))

# convert gridded raster data dataframe
forest_change_df <- forest_change %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

forest_change_subset_df <- forest_change_subset %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

orthomosaic_df <- orthomosaic %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

qa_df <- qa %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

orthomosaic_subset_df <- orthomosaic_subset %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

# maps
forest_change_map <- ggplot()+
  geom_tile(data = forest_change_df, aes(x=x,y=y,fill=as.factor(val))) +
  scale_fill_brewer(palette = "Paired",
                    labels=c(" permanent forest cover",
                             " reforestation >1958",
                             " deforestation >2000",
                             " deforestation >1958 (permanent)")) +
  coord_fixed(ratio = 1) +
  geom_sf(data = bb, colour = "white", fill = NA, size = 0.8) +
  ylim(c(0.725,1.07)) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(x = "",
       y = "")

forest_change_subset_map <- ggplot()+
  geom_tile(data = forest_change_subset_df,
            aes(x=x,y=y,fill=as.factor(val))) +
  scale_fill_brewer(palette = "Paired",
                    labels=c(" permanent forest cover",
                             " reforestation >1958",
                             " deforestation >2000",
                             " deforestation >1958 (permanent)")) +
  coord_fixed(ratio = 1) +
  geom_sf(data = bb, colour = NA, fill = NA) +
  theme_minimal() +
  theme(legend.title = element_blank(),
        legend.position="bottom",
        legend.direction="horizontal",
        legend.text = element_text(size = 13),
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(x = "",
       y = "")

orthomosaic_map <- ggplot()+
  geom_tile(data = orthomosaic_df, aes(x=x,y=y,fill=val)) +
  scale_fill_gradient(low = "black", high = "white") +
  coord_fixed(ratio = 1) +
  geom_sf(data = h_area,
          colour = "white",
          fill = NA,
          aes(lty = type),
          size = 0.8,
          guide = "none") +
  ylim(c(0.725,1.07)) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

qa_map <- ggplot()+
  geom_tile(data = qa_df, aes(x=x,y=y,fill=val)) +
  scale_fill_gradient(low = "#1f78b4", high = "#a6cee3",
                      name = "Forest Cover\n probability") +
  coord_fixed(ratio = 1) +
  geom_sf(data = h_area,
          fill = NA,
          aes(lty = type, colour = cnn),
          size = 0.8,
          na.rm = FALSE) +
  scale_colour_manual(values = c(
    "#e31a1c",
    "#33a02c",
    "#ff7f00"),
    name = "") +
  geom_sf(data = cloud_mask,
          colour = "black",
          fill = NA,
          lty = 1,
          size = 0.8) +
  ylim(c(0.725,1.07)) +
  theme_minimal() +
  guides(fill = "legend", lty = "none") +
  theme(legend.position="bottom",
        legend.direction = "horizontal",
        legend.text = element_text(size = 13),
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_blank(),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

orthomosaic_subset_map <- ggplot()+
  geom_tile(data = orthomosaic_subset_df, aes(x=x,y=y,fill=val)) +
  scale_fill_gradient(low = "black", high = "white") +
  coord_fixed(ratio = 1) +
  geom_sf(data = bb, colour = NA, fill = NA) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_blank(),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

p1 <- plot_grid(orthomosaic_subset_map,
               forest_change_subset_map + theme(legend.position = "none"),
               nrow = 2,
               align = "hv",
               axis= "tblr",
               labels = c("B", "C"))

p2 <- plot_grid(forest_change_map,
                p1,
                nrow = 1,
                axis= "tblr",
                labels = c("A", ""))

p_cover <- plot_grid(
  p2,
  get_legend(forest_change_subset_map),
  nrow = 2,
  rel_heights = c(1, .1))

p3 <- plot_grid(orthomosaic_map,
                qa_map + theme(legend.position = "none"),
                nrow=1,
                align = "hv",
                axis= "tblr",
                labels = c("A", "B")
                )

p_ortho <- plot_grid(p3,
               get_legend(qa_map),
               nrow = 2,
               rel_heights = c(1, .1))

save_plot("manuscript/figures/forest_cover_map.png",
          p_cover,
          base_height = 11,
          base_width = 13,
          dpi = 300)

save_plot("manuscript/figures/orthomosaic_maps.png",
          p_ortho,
          base_height = 11,
          base_width = 13,
          dpi = 300)
