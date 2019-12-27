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

# histogram matching
geoeye_r <- histMatch(geoeye_r, historical)

# reproject to work in meters not degrees

# create subsets of at least 500x500 m
# then apply a global normalized analysis in foto using
# a window size equivalent to roughly 150m or 150px
# moving window to assure good coverage
# then extract buffered extraction of these values
# for 50m around the site location to get a metric
# of

# offset of approximately ~200m in degrees
offset <- 0.00182

# calculate the historical subsets
apply(locations,1,function(l){
  x <- as.numeric(l['lon'])
  y <- as.numeric(l['lat'])

  filename <- paste0("./data/foto/psp/",
                     l["type"],
                     "_",
                     l["nr"],
                     "_historical.tif")

  if(!file.exists(filename)){

    subset <- crop(historical, extent(c(x - offset,
                                        x + offset,
                                        y - offset,
                                        y + offset)))

    writeRaster(subset,
                filename,
                options = c("COMPRESS=DEFLATE"),
                overwrite = TRUE,
                datatype='INT1U')
  }
})

# calculate the contemporary subsets
apply(locations,1,function(l){

  x <- as.numeric(l['lon'])
  y <- as.numeric(l['lat'])

  subset <- try(crop(geoeye_r, extent(c(x - offset,
                                    x + offset,
                                    y - offset,
                                    y + offset))))

  if(inherits(subset, "try-error")){
    return(NULL)
  } else {

    filename <- paste0("./data/foto/psp/",
                       l["type"],
                       "_",
                       l["nr"],
                       "_geo-eye.tif")

    if(!file.exists(filename)){
      writeRaster(subset,
                  filename,
                  options = c("COMPRESS=DEFLATE"),
                  overwrite = TRUE,
                  datatype='INT1U')
    }
  }
})

# calculate or locad FOTO pca values
if(!file.exists("./data/foto/psp/pca_values.rds")){
  pca_values <- foto::foto_batch("./data/foto/psp/",
                        window_size = 187,
                        method = "mw",
                        cores = 20)

  # save as rds file
  saveRDS(pca_values, "./data/foto/psp/pca_values.rds")
} else {
  pca_values <- readRDS("./data/foto/psp/pca_values.rds")
}

# extract the first principle component (PC)
# for further analysis
pc <- unlist(lapply(pca_values,
                    function(r){
  v <- try(raster::extract(r$layer.1,
          cbind(locations$lon, locations$lat),
          buffer = 50))
  v <- unlist(lapply(v,
                     function(x){if(!all(is.na(x))){
                       median(x, na.rm = TRUE)}}))
  return(v)
}))

# combine data
df <- data.frame(do.call("rbind",strsplit(names(pc),"_")))
names(df) <- c("type","nr","era")
df$era <- tools::file_path_sans_ext(df$era)
df$pc <- pc

# extract historical forest status
forest_cover <- raster("./data/orthomosaic/yangambi_forest_cover_difference_1958_2000.tif")
locations$forest_cover <- raster::extract(forest_cover,
                                cbind(locations$lon,
                                      locations$lat),
                                buffer = 50,
                                fun = median)

df <- merge(df, locations, by = c("type","nr"), all.x = TRUE)

# exclude mono-dominant 4 (clouds)
# mixed 3 (partial coverage at edge geo-eye) values (set to NA)
df$pc[which(df$type == "mono-dominant" & df$nr == 4)] <- NA
df$pc[which(df$type == "mixed" & df$nr == 3)] <- NA

# write the final data to disk
saveRDS(df, "./data/foto/psp/pc1_values.rds")
