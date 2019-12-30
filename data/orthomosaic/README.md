# Details on the included orthomosaic data and derivatives

The data in this folder pertain to the historical orthomosaics as described in the repository's main manuscript. However not all data are fit for use in subsequent analysis, without consulting the manuscript.

Only the full resolution file should be considered, when it comes to the orthomosaic (i.e. the final modified file `yangambi_orthomosaic_modified.tif as used in code). However, due to file size restrictions on github the full resolution data file is distributed through a zenodo repository at https://doi.org/10.5281/zenodo.3547767. 

All "resampled" files refer to the downsampling to reduce the resolution to that of the Hansen et al. forest cover change data for a long term land use and land cover change analysis (or by proxy also to speed up the generation of certain figures). In this context, both `yangambi_forest_mask_resampled.tif` and `yangambi_forest_cover_difference_1958_2000.tif` can also be considered valid research results fit for re-use, given the restrictions that resampling imposes.
