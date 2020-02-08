library(raster)
library(tidyverse)

# load raster
change_map <- raster("./data/orthomosaic/yangambi_forest_cover_difference_1958_2000.tif")
change_map <- projectRaster(change_map, crs = "+init=epsg:3395",method = "ngb")
change_map <- trim(change_map)

# read site data estimates of AGC
psp <- read.table("./data/surveys/site_characteristics.csv",
                  header = TRUE,
                  sep = ",")
agc <- psp %>%
  group_by(type) %>%
  summarize(mean = mean(above.ground.C.stock..Mg.C.ha.1.),
            median = median(above.ground.C.stock..Mg.C.ha.1.),
            sd = sd(above.ground.C.stock..Mg.C.ha.1.),
            n = length(above.ground.C.stock..Mg.C.ha.1.))

# test if the two plot sets (edge and mixed) come from
# significantly different populations or not
df <- psp %>%
  filter(type == "edge" | type == "mixed") %>%
  mutate(species.richness = as.double(species.richness))
wilcox.test(above.ground.C.stock..Mg.C.ha.1. ~ type, data = df)
wilcox.test(stem.density..ha.1. ~ type, data = df)
wilcox.test(basal.area....m2.ha.1. ~ type, data = df)
wilcox.test(species.richness ~ type, data = df)
# p > 0.05, same population

# select patches
p <- change_map >= 3
p[p==0] <- NA

# buffer the non-forest areas by 400m (extending into forested areas)
# See phillips et al. 2006 / Gascon et al. 2000 for rational
# (few changes after 400m in biomass) and the survey methodology
#pe <- buffer(p, 400, doEdge=TRUE)

# report 200m in the final paper, as AGC not significantly different
# for edge plots (rerun)
pe <- buffer(p, 200, doEdge=TRUE)

# calculate edge forest
edge_values <- change_map == 1 & pe == 1
edge_values[is.na(edge_values)] <- 0

# print the map frequency statistics
change_stats <- as.data.frame(freq(change_map, useNA='no'))

# add a line for edges
change_stats <- rbind(change_stats,c(5,freq(edge_values)[2,2]))

# convert from pixel count to square km/m and ha
# assuming a pixel size of ~30m
change_stats$sq_km <- change_stats$count * 0.03^2
change_stats$ha <- change_stats$sq_km / 0.01

# calcualte absolute surface area of the scene
# not approximation
total_ha_scene <- round(sum(change_stats$ha[1:4]))

mean_mixed_agc <- agc$mean[agc$type=="mixed"]
sd_mixed_agc <- agc$sd[agc$type=="mixed"]

print(paste(mean_mixed_agc, sd_mixed_agc, sep = " +_ "))

agc_high <-
  round(change_stats$ha * agc$mean[agc$type=="mixed"]/1000)

agc_high_sd <-
  round(change_stats$ha * agc$sd[agc$type=="mixed"]/1000)

agc_low <-
  round(change_stats$ha * agc$mean[agc$type=="old-regrowth"]/1000)

change_stats$agc <- agc_high
change_stats$agc[3:4] <- paste(agc_high[3:4], agc_high_sd[3:4], sep = " $\\pm$ ")
change_stats$agc[2] <- paste(agc_low[2], agc_high[2], sep = " - ")

change_stats <-  change_stats %>%
  mutate(sq_km = round(sq_km),
         ha = round(ha))

# select final values to report
change_stats <- change_stats %>%
  select(-c("value","count"))

# reshuffle rows
change_stats <- change_stats[c(1,5,2:4),]
#change_stats <- rbind(as.numeric(c(NA, total_ha_scene, NA)), change_stats)

write.table(change_stats,
            "./data/surveys/lulcc_change_stats.csv",
            row.names = FALSE,
            col.names = TRUE,
            quote = TRUE,
            sep = ",")

