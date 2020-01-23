# plot comparison of spectral and spatial
# classifiers

# load raster library
library(raster)
library(tidyverse)
library(cowplot)
library(sf)

# read cloud mask
cloud_mask <- st_read("data/maps/geo_eye_cloud_mask.shp")

# read in cnn forest mask
m <- raster("./data/geo-eye/geo-eye_forest_mask_cnn.tif")

# hansen
hans <- raster("./data/Hansen_et_al/Hansen_GFC_lossyear_yangambi.tif")

# read in Hansen map (get all forest loss before and in 2011)
hans <- raster("data/Hansen_et_al/Hansen_GFC_lossyear_yangambi.tif")
hans <- crop(hans, extent(m))
loss <- (hans <= 11) + (hans == 0)
loss <- (loss > 1)
loss[is.na(loss)] <- 4
loss[loss == 1] <- 5

# box in detailed feature
box <- st_as_sfc(st_bbox(c(
  xmin = 24.47501,
  xmax = 24.48995,
  ymin = 0.80304,
  ymax = 0.81505
), crs = st_crs(4326)))

# combine maps
loss_final <- loss + m

# read in geo-eye downsampled data
r <- raster("data/geo-eye/geo-eye_panchromatic_latlon_resampled_8bit.tif")
geoeye_r <- aggregate(r, fact = 8)

geoeye_df <- geoeye_r %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

class_map <- loss_final %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

geoeye_map <- ggplot()+
  geom_tile(data = geoeye_df, aes(x=x,y=y,fill=val)) +
  scale_fill_gradient(low = "black", high = "white") +
  coord_fixed(ratio = 1) +
  geom_sf(data = cloud_mask,
          colour = "white",
          fill = NA,
          lty = 1,
          size = 0.8) +
  geom_sf(data = box,
          colour = "white",
          fill = NA,
          lty = 2,
          size = 0.8) +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

spatial_map <- ggplot()+
  geom_tile(data = class_map,
            aes(x=x,y=y,fill=as.factor(val))) +
  scale_fill_manual(values = rev(c("#a6cee3",
                      "#1f78b4",
                      "#b2df8a",
                      "#33a02c")),
                    labels=c("non-forest (GFC + CNN)",
                             "non-forest (GFC)",
                             "non-forest (CNN)",
                             "forest (GFC + CNN)")) +
  coord_fixed(ratio = 1) +
  geom_sf(data = box,
          colour = "white",
          fill = NA,
          lty = 2,
          size = 0.8) +
  theme_minimal() +
  theme(legend.title = element_blank(),
        legend.position="bottom",
        legend.direction="horizontal",
        legend.text = element_text(size = 8),
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(
    x = "",
    y = "")

p <- plot_grid(geoeye_map,
               spatial_map,
               nrow = 1,
               align = "hv",
               axis= "tblr",
               labels = c("A", "B"),
               label_x = 0)

save_plot("./manuscript/figures/visual_comparison_classifiers.png",
          p,
          base_width = 13,
          base_height = 6,
          dpi = 350)
