# plot comparison of spectral and spatial
# classifiers

# load raster library
library(raster)
library(tidyverse)
library(cowplot)

# read in cnn forest mask
m <- raster("./data/geo-eye/geo-eye_forest_mask_cnn.tif")

# hansen
hans <- raster("./data/Hansen_et_al/Hansen_GFC_lossyear_yangambi.tif")

# read in Hansen map (get all forest loss before 2013)
hans <- raster("data/Hansen_et_al/Hansen_GFC_lossyear_yangambi.tif")
hans <- crop(hans, extent(m))
loss <- (hans <= 12) + (hans == 0)
loss <- (loss > 1)
loss[is.na(loss)] <- 4
loss[loss == 1] <- 5

# combine maps
loss_final <- loss + m

# read in geo-eye downsampled data
r <- raster("data/geo-eye/geo-eye_panchromatic_latlon_resampled_8bit.tif")
geoeye_r <- aggregate(r, fact = 6)

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
  scale_fill_brewer(palette = "Paired",
                    labels=c("GFC + CNN",
                             "GFC",
                             "CNN",
                             "forest")) +
  coord_fixed(ratio = 1) +
  theme_minimal() +
  theme(legend.title = element_blank(),
        legend.position="bottom",
        legend.direction="horizontal",
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
               label_x = 0.9)

save_plot("./manuscript/figures/visual_comparison_classifiers.png",
          p,
          base_width = 7.5,
          base_height = 4,
          dpi = 300)
