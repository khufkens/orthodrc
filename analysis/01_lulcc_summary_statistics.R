# some summary statistics on land use land cover change
# in particular quickly figure out what the status was
# of the sites in the old imagery
library(raster)

# read in site loctions and the lulcc map
# to cross reference the state of the forest
# within a historical perspective

locations <- read.table("data/surveys/site_characteristics.csv",
                        sep = ",",
                        header = TRUE)

lulcc <- raster("data/orthomosaic/yangambi_forest_cover_difference_1958_2000.tif")

# Define lat / lon projection.
lat_lon <- CRS("+init=epsg:4326")

# Read in the coordinates and assign them a projection
ll <- SpatialPoints(cbind(locations$lon,locations$lat), lat_lon)

# stuff results into original dataframe
locations$lulcc_100 <- raster::extract(lulcc, ll, buffer = 100)
locations$lulcc_summary <- lapply(locations$lulcc_100, function(x){
  s <- table(x)
  s <- round(s/sum(s)*100)
  n <- names(s)
  paste(paste(s," (",n,")", sep = ""), collapse = ", ")
  })

# results basically show that everything was forest in 1958
# this includes old and young regrowth forests
# indicating that old regrowth is older than 60 years while
# the young regrowth is younger than 60 years in age
print(locations)


