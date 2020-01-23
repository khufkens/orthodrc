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
library(rnaturalearthdata)
library(sf)
library(cowplot)
library(rgdal)

flight_paths = "./data/maps/flight_path_detail.tif"
orthomosaic = "./data/orthomosaic/yangambi_orthomosaic_modified_resampled.tif"
geoeye = "./data/geo-eye/geo-eye_panchromatic_latlon.tif"
mab_outline = "./data/maps/"

nc <- sf::st_read("data/maps/mab_ll.shp", quiet = TRUE)
r <- brick(flight_paths)

s <- read.table("./data/surveys/site_characteristics.csv",
                sep = ",",
                header = TRUE)

y <- raster(orthomosaic)
y_e <- st_as_sfc(st_bbox(y))
bbox <- st_bbox(y)

g <- raster(geoeye)
g_e <- st_as_sfc(st_bbox(g))

# load yangambi reserve boundaries
e <- extent(c(24.35, 24.7, 0.7, 1.1))
r <- crop(r, e)
r_e <- st_as_sfc(st_bbox(r))
nc <- sf::st_intersection(nc, r_e)

# convert raster map to dataframe
r_df <- r %>%
  rasterToPoints %>%
  as.data.frame() %>%
  `colnames<-`(c("x", "y", "val"))

# constructing raster map
r_map <- ggplot()+
  geom_tile(data = r_df, aes(x=x,y=y,fill = val)) +
  scale_fill_gradient(low = "#1f78b4", high = "white") +
  coord_fixed(ratio = 1)

# adding vector data
r_map <- r_map +
  geom_sf(data = nc,
          aes(alpha = 0.8),
          fill = "grey",
          colour = NA) +
  geom_sf(data = y_e,
          colour = "grey25",
          fill = NA,
          size = 0.8) +
  geom_sf(data = g_e,
          colour = "grey25",
          fill = NA,
          linetype = "dashed",
          size = 0.8) +
  geom_point(data = s,
             aes(x = lon,
                 y = lat,
                 shape = type),
             col = "black",
             alpha = 1,
             size = 1.5) +
  scale_shape_manual(values = c(0, 1, 2, 3, 4, 5))

# theme map
r_map <- r_map +
  theme_minimal() +
  theme(legend.position="none",
        axis.text = element_text(size = 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_line(colour="grey"),
        panel.grid.minor = element_line(colour="grey")) +
  labs(x = "",
       y = "")

world <- ne_countries(scale='medium', returnclass = 'sf')
drc <- subset(world, admin == "Democratic Republic of the Congo")

drc_inset <- ggplot(data = drc) +
  geom_sf(fill = "grey25",
          lwd = 0) +
  theme_map() +
  theme(legend.position = "none",
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill="white",
                                        colour = "grey25",
                                        size = 1.5)) +
  geom_rect(xmin = bbox["xmin"],
            xmax = bbox["xmax"],
            ymin = bbox["ymin"],
            ymax = bbox["ymax"],
            fill = NA,
            colour = "white",
            size = 1)

r_map <- r_map +
  annotation_custom(
    grob = ggplotGrob(drc_inset),
     xmin = 24.6,
     xmax = 24.7,
     ymin = 1.0,
     ymax = 1.1
  )

ggsave("manuscript/figures/flight_paths.png",
        width = 5,
        dpi = 300)
