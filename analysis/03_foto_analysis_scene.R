# Foto analysis of canopy texture
library(raster)
library(foto)
library(tools)
library(RStoolbox)

# read in site location + other info
locations <- read.table("./data/surveys/site_characteristics.csv",
                        sep = ",",
                        header = TRUE)

# downsample the geo-eye image to the resolution
# of the historical data
historical <- raster("./data/orthomosaic/yangambi_orthomosaic_modified.tif")

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

# calculate FOTO pca values
if(!file.exists("./data/foto/scene/pca_values.rds")){

  # crop orthomosaic
  historical <- crop(historical, extent(geoeye_r))

  # histogram matching
  geoeye_r <- histMatch(geoeye_r, historical)

  # write to file for batch processing
  dir.create(file.path(tempdir(),"/foto"))
  writeRaster(geoeye_r,file.path(tempdir(),"/foto/geoeye.tif"),
              overwrite = TRUE)
  writeRaster(historical,
              file.path(tempdir(),"/foto/historical.tif"),
              overwrite = TRUE)

  pca_values <- foto_batch(file.path(tempdir(),"/foto/"),
                           window_size = 187,
                           method = "zones",
                           cores = 2)

  # save as rds file
  saveRDS(pca_values, "./data/foto/scene/pca_values.rds")
} else {
  pca_values <- readRDS("./data/foto/scene/pca_values.rds")
}

# extract historical forest status
forest_cover <- raster("./data/orthomosaic/yangambi_forest_cover_difference_1958_2000.tif")
locations$forest_cover <- raster::extract(forest_cover,
                                          cbind(locations$lon,
                                                locations$lat),
                                          buffer = 50,
                                          fun = median)

locations$`geo-eye` <- raster::extract(pca_values$geoeye.tif$layer.1,
                                          cbind(locations$lon,
                                                locations$lat),
                                          buffer = 50,
                                          fun = median)

locations$historical <- raster::extract(pca_values$historical.tif$layer.1,
                                     cbind(locations$lon,
                                           locations$lat),
                                     buffer = 50,
                                     fun = median)

# write the final data to disk
saveRDS(locations, "./data/foto/scene/pc1_values.rds")
