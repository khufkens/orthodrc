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
library(RStoolbox)
library(scales)

# downsample the geo-eye image to the resolution
# of the historical data
historical <- raster("./data/orthomosaic/yangambi_orthomosaic_modified.tif")

s <- read.table("./data/surveys/site_characteristics.csv",
                sep = ",",
                header = TRUE)

if(!file.exists("./data/geo-eye/geo-eye_panchromatic_latlon_resampled.tif")){
  message("resampling geo-eye data")
  geoeye <- raster("./data/geo-eye/geo-eye_panchromatic_latlon.tif")
  geoeye_r <- resample(geoeye, historical)
  geoeye_r <- crop(geoeye_r,extent(geoeye))
  writeRaster(geoeye_r,
              "./data/geo-eye/geo-eye_panchromatic_latlon_resampled.tif")
} else {
  message("reading in geo-eye data")
  geoeye_r <- raster("./data/geo-eye/geo-eye_panchromatic_latlon_resampled.tif")
}

# aggregate (lower resolution for plotting)
geoeye_r <- aggregate(geoeye_r, fact = 6)
historical <- crop(historical, extent(geoeye_r))
historical <- aggregate(historical, fact = 6)
geoeye_r <- histMatch(geoeye_r, historical)

# grab extent of the data and crop out locations
# based on this (to avoid growing the region of interest)
e <- st_as_sfc(st_bbox(historical))
s <- st_as_sf(s,
              coords = c(5,4),
              crs = 4326,
              agr = "constant")
s <- sf::st_intersection(s, e)

# read pca values
pca_values <- readRDS("./data/foto/scene/pca_values.rds")

# convert gridded raster data dataframe
geoeye_df <- geoeye_r %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

historical_df <- historical %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

geoeye_foto_df <- pca_values$geoeye.tif %>%
  rasterToPoints %>%
  as.data.frame()

historical_foto_df <- pca_values$historical.tif %>%
  rasterToPoints %>%
  as.data.frame()

# mapping code
historical_map <- ggplot()+
  geom_tile(data = historical_df, aes(x=x,y=y,fill=val)) +
  scale_fill_gradient(low = "black", high = "white") +
  coord_fixed(ratio = 1) +
  geom_sf(data = s,
          aes(shape = type,
              size = 3), stroke = 2, colour = "white") +
  scale_shape_manual(values = c(0, 1, 2, 3, 4)) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

geoeye_map <- ggplot()+
  geom_tile(data = geoeye_df, aes(x=x,y=y,fill=val)) +
  scale_fill_gradient(low = "black", high = "white") +
  coord_fixed(ratio = 1) +
  geom_sf(data = s,
          aes(shape = type, size = 3), stroke = 2,colour = "white") +
  scale_shape_manual(values = c(0, 1, 2, 3, 4)) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

historical_foto_map <- ggplot()+
  geom_tile(data = historical_foto_df,
            aes(x=x,y=y,fill=rgb(layer.1,layer.2,layer.3))) +
  scale_fill_identity() +
  coord_fixed(ratio = 1) +
  geom_sf(data = s,
          aes(shape = type, size = 3), stroke = 2, colour = "white") +
  scale_shape_manual(values = c(0, 1, 2, 3, 4)) +
  theme_minimal()  +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

geoeye_foto_map <- ggplot()+
  geom_tile(data = geoeye_foto_df,
            aes(x=x,y=y,fill=rgb(layer.1,layer.2,layer.3))) +
  scale_fill_identity() +
  coord_fixed(ratio = 1) +
  geom_sf(data = s,
          aes(shape = type, size = 3), stroke = 2, colour = "white") +
  scale_shape_manual(values = c(0, 1, 2, 3, 4)) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

p <- plot_grid(historical_map,
               historical_foto_map,
               geoeye_map,
               geoeye_foto_map,
               nrow = 2,
               align = "hv",
               axis= "tblr",
               labels = c("A", "B", "C", "D"),
               label_x = 0.9)

save_plot("manuscript/figures/foto_maps.png",
          p,
          base_height = 12,
          base_width = 12,
          dpi = 300)

# plot the comparison between mono-dominant 6 past and current

historical <- raster("data/foto/psp/mono-dominant_6_historical.tif")
geoeye <- raster("data/foto/psp/mono-dominant_6_geo-eye.tif")

geoeye <- RStoolbox::histMatch(geoeye, historical)

# convert gridded raster data dataframe
geoeye_df <- geoeye %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

historical_df <- historical %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

# mapping code
historical_map <- ggplot()+
  geom_tile(data = historical_df, aes(x=x,y=y,fill=val)) +
  scale_fill_gradient(low = "black", high = "white") +
  #coord_fixed(ratio = 1) +
  #geom_sf(data = s,
  #        aes(shape = type, size = 3), colour = "white") +
  #scale_shape_manual(values = c(0, 1, 2, 4)) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

geoeye_map <- ggplot()+
  geom_tile(data = geoeye_df, aes(x=x,y=y,fill=val)) +
  scale_fill_gradient(low = "black", high = "white") +
  #coord_fixed(ratio = 1) +
  #geom_sf(data = s,
  #        aes(shape = type, size = 3), colour = "white") +
  #scale_shape_manual(values = c(0, 1, 2, 4)) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

p <- plot_grid(historical_map,
               geoeye_map,
               ncol = 2,
               align = "hv",
               axis= "tblr",
               labels = c("A", "B"),
               label_x = 0.9)

save_plot("manuscript/figures/visual_comparison_psp.png",
          p,
          base_width = 7.5,
          base_height = 3.8,
          dpi = 150)
