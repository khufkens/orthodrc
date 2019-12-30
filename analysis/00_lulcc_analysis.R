# This script calculates the difference in forest cover
# between the manual classification of the historical
# orthomosaic data and the recent Hansen et al. 2013
# global forest change map.
#
# I only consider true untouched forest in the period
# 2000 - 2018 in this analysis.

# load required libraries
library(raster)

# download full resolution file from Zenodo repo
# if the data does not exist (cloned project from github)
if(!file.exists("data/orthomosaic/yangambi_orthomosaic_modified.tif")){
download.file("download. https://zenodo.org/api/files/8039915b-30ea-4b2c-a799-04ef0aadf0ec/yangambi_orthomosaic.tif?versionId=7003f8f2-a826-496e-b4f1-698d2e89b76e",
              "data/orthomosaic/yangambi_orthomosaic_modified.tif")
}

# read outline of the mosaic
m <- raster("data/orthomosaic/yangambi_orthomosaic_mask_resampled.tif")

# read in forest mask (historical)
yangambi <- raster("data/orthomosaic/yangambi_forest_mask_resampled.tif")
yangambi[yangambi == 2] <- 5
yangambi[is.na(yangambi)] <- 8
yangambi <- mask(yangambi, m, maskvalue = NA)

# read in Hansen map, crop/mask to fit the historical data for speed
hansen <- raster("data/Hansen_et_al/Hansen_GFC_lossyear_yangambi.tif")
hansen <- crop(hansen, extent(yangambi))
hansen <- mask(hansen, m, maskvalue = NA)

# select forests with no loss between 2000 and 2018
hansen[hansen > 0] <- 1

# difference between the maps
# and reclassify the data
change_map <- yangambi - hansen

# in the final map values are,
# 1: remaining untouched forest
# 2: reforestation 1958 - 2000
# 3: deforestation in period 2000 - 2018
# 4: deforestation in 1958 until now
change_map <- reclassify(change_map, c(3,4,3,
                                       4,5,1,
                                       7,8,2,
                                       6,7,4))

# print the map frequency statistics
change_stats <- as.data.frame(freq(change_map, useNA='no'))

# convert from pixel count to square km/m and ha
# assuming a pixel size of ~30m
change_stats$sq_m <- change_stats$count * 30^2
change_stats$sq_km <- change_stats$count * 0.03^2
change_stats$ha <- change_stats$sq_m / 10000

change_stats$labels <- c(" no change",
         " forest regrowth > 1958",
         " forest loss > 2000",
         " forest loss > 1958")

# print the forest change stats to console
print(change_stats)

# write data to disk for further analysis
writeRaster(change_map,
"data/orthomosaic/yangambi_forest_cover_difference_1958_2000.tif",
 overwrite = TRUE)
