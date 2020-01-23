# select CNN training site from shapefile

# load libraries
library(raster)
library(rgdal)

# load orthomosaic to subset
img <- raster("./data/orthomosaic/yangambi_orthomosaic_modified.tif")

# read in shapefile location digitized in QGIS
loc <- readOGR("data/cnn/","sample_locations")

# grab the cell values and convert to coordinates (row/col)
cell_values <- extract(img, loc, cellnumbers = TRUE)[,'cells']
coords <- data.frame(rowColFromCell(img, cell_values),
                type = as.character(as.data.frame(loc)$type))

img_size <- 256

#nrow(coords)
for (i in 1:nrow(coords)){
  row <- coords[i,'row']
  col <- coords[i,'col']
  type <- coords[i,'type']

  img_subset <- crop(img, extent(img,
                                 row - (img_size + 1),
                                 row + img_size,
                                 col - (img_size + 1),
                                 col + img_size))
  img_subset[is.na(img_subset)] <- 0

  jpeg(file.path("./data/cnn/images",paste0(type,"_",i,".jpg")),
      (img_size * 2) + 1,
      (img_size * 2) + 1,
      quality = 100)
  par(oma=rep(0,4), mar=rep(0,4))
  image(img_subset, col = grey(1:255/256),
        xaxt = 'n',
        yaxt = 'n',
        xlab = '',
        ylab = '',
        bbox = 'n')
  dev.off()
}
