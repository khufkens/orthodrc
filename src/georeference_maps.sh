#!/bin/bash

# conversion georeference scripts using ground control points
# on buildings, river crossings and constrained by river intersections at
# the outer boundaries nearest neighbour using a polynomial of order 3

# Polynomial order 3

# TPS mean error
# orthomosaic: 11.5477 m / pixels
# DEM: 0.22134 m / pixels

gdal_translate -of GTiff -gcp 24.4884 -0.754953 24.4885 0.754908 -gcp 24.4631 -0.762446 24.4631 0.762428 -gcp 24.4449 -0.765972 24.4449 0.766006 -gcp 24.3953 -0.774552 24.3957 0.774467 -gcp 24.4565 -0.800831 24.4565 0.800806 -gcp 24.4549 -0.780972 24.455 0.780964 -gcp 24.5942 -0.761086 24.5942 0.761027 -gcp 24.4586 -0.831196 24.4586 0.831191 -gcp 24.4424 -0.834813 24.4424 0.834928 -gcp 24.4638 -0.868746 24.4638 0.868703 -gcp 24.4885 -1.04527 24.4886 1.04534 -gcp 24.4932 -1.04606 24.4933 1.04611 -gcp 24.4073 -1.01719 24.4073 1.01752 -gcp 24.4428 -0.767977 24.4427 0.767981 -gcp 24.3699 -0.925589 24.3705 0.925278 -gcp 24.6132 -0.92235 24.6127 0.922348 -gcp 24.4341 -0.731394 24.4341 0.731337 "yangambi_orthomosaic.tif" "/tmp/yangambi_orthomosaic.tif"
gdalwarp -r near -order 3 -co COMPRESS=DEFLATE  "/tmp/yangambi_orthomosaic.tif" "yangambi_orthomosaic_modified_poly3.tif"

