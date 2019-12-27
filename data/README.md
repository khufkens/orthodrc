# Data

This folder contains all data used in the analysis and includes in various subfolders:

- GEO-EYE panchromatic images referenced in code but excluded from the github repo due to copyright issues `data/geo-eye`
- Subsets of the [Hansen et al. 2013 Global Forest Change data (v1.6)](https://earthenginepartners.appspot.com/science-2013-global-forest/download_v1.6.html) of tile 10N 02E `data/hansen_et_al`
- gis mapping components `data/maps`
- the Yangambi orthomosaic `data/orthomosaic`
- permanent sampling plot survey data `data/surveys`

## Yangambi orthomosaic

Within the context of the analysis the orthomosaic folder is the most important one. It contains the orthomosaic of the larger Yangambi region, the downsampled forest cover mask and the resulting forest cover change map (i.e. the difference with the contemporary Hansen et al. 2013 data). The digital elevation map used in composing the orthomosaic is also provided.

Original Metashape files are listed in the `data-raw` folder while the final geo-referenced files end in *_modified.tif. All other data subfolders are used in the generation of figures in the paper or for the generation of the results in the orthomosaic folder (e.g. the Hansen et al. 2013 data).
