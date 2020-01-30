library(tidyverse)
library(raster)
library(sf)

#---- analysis psp snippets
psp <- readRDS("./data/foto/psp/pc1_values.rds")
psp$nr <- as.numeric(psp$nr)
psp <- psp[!(psp$type == "mono-dominant" & psp$nr == 4),]

# remove old regrowth
psp <- psp %>%
  filter(type != "old-regrowth")

p <- ggplot(psp, aes(x=type, y=pc, fill = era)) +
  geom_boxplot() +
  theme_minimal() +
  labs(y = "PC 1",
       x = "") +
  theme(legend.title = element_blank(),
        legend.position="bottom",
        text = element_text(size=20)) +
  scale_fill_manual(
    values=c("#1f78b4","#a6cee3")) +
  coord_flip()

ggsave("manuscript/figures/foto_bplot_psp.png",
       p,
       width = 7,
       dpi = 150)

# AGC plot
p <- ggplot(psp) +
  geom_point(aes(x = pc,
                 y = above.ground.C.stock..Mg.C.ha.1.,
                 pch = type),
             cex = 4) +
  labs(y = expression("Above Ground Carbon (Mg C ha"^-1 * ")"),
       x = "PC 1") +
  scale_shape_discrete(name = "Forest Type") +
  theme_minimal() +
  theme(axis.text = element_text(size = 15),
        axis.title = element_text(size = 15),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 15),
        strip.text = element_text(size = 15)) +
  facet_wrap(~ era)

ggsave("./manuscript/figures/foto_pc1_agc.png",
       p,
       width = 12,
       height = 6,
       dpi = 150)

print(summary(lm(psp$pc ~ psp$above.ground.C.stock..Mg.C.ha.1.)))

# richness plot
p <- ggplot(psp) +
  geom_point(aes(x = pc,
                 y = species.richness,
                 pch = type),
             cex = 4) +
  labs(y = "Species richness",
       x = "PC 1") +
  scale_shape_discrete(name = "Forest Type") +
  theme_minimal() +
  theme(axis.text = element_text(size = 15),
        axis.title = element_text(size = 15),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 15),
        strip.text = element_text(size = 15)) +
  facet_wrap(~ era)

ggsave("./manuscript/figures/foto_pc1_diversity.png",
       p,
       width = 12,
       height = 6,
       dpi = 150)

print(summary(lm(psp$pc ~ psp$species.richness)))

# stem density plot
p <- ggplot(psp) +
  geom_point(aes(x = pc,
                 y = stem.density..ha.1.,
                 pch = type),
             cex = 4) +
  labs(y = expression("Stem density (ha"^-1*")"),
       x = "PC 1") +
  scale_shape_discrete(name = "Forest Type") +
  theme_minimal() +
  theme(axis.text = element_text(size = 15),
        axis.title = element_text(size = 15),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 15),
        strip.text = element_text(size = 15)) +
  facet_wrap(~ era)

ggsave("./manuscript/figures/foto_pc1_stems.png",
       p,
       width = 12,
       height = 6,
       dpi = 150)

print(summary(lm(psp$pc ~ psp$stem.density..ha.1.)))

psp <- spread(psp, key = era, value = pc)
psp <- psp %>%
  filter(type != "fallow",
         type != "young-regrowth")

print(wilcox.test(psp$`geo-eye`, psp$historical, paired = TRUE))

# visual comparison stats

psp %>%
  filter(type == "mono-dominant",
         nr != 6) %>%
  summarize(pc_mean = round(mean(historical, na.rm = TRUE),2),
            pc_sd = round(sd(historical, na.rm = TRUE),2)) %>%
  print()

psp %>%
  filter(type == "mixed") %>%
  summarize(pc_mean = round(mean(historical, na.rm = TRUE),2),
            pc_sd = round(sd(historical, na.rm = TRUE),2)) %>%
  print()

psp %>%
  filter(type == "mono-dominant",
         nr != 6) %>%
  summarize(pc_mean = round(mean(`geo-eye`, na.rm = TRUE),2),
            pc_sd = round(sd(`geo-eye`, na.rm = TRUE),2)) %>%
  print()

psp %>%
  filter(type == "mixed") %>%
  summarize(pc_mean = round(mean(`geo-eye`, na.rm = TRUE),2),
            pc_sd = round(sd(`geo-eye`, na.rm = TRUE),2)) %>%
  print()


#--- analysis full scene
scene <- readRDS("./data/foto/scene/pc1_values.rds")
scene <- scene %>%
  filter(type != "fallow",
         type != "young-regrowth",
         type != "old-regrowth")
scene <- scene[!(scene$type == "mono-dominant" & scene$nr == 4),]
print(wilcox.test(scene$`geo-eye`, scene$historical, paired = TRUE))

scene <- scene %>%
  dplyr::select("type",
         "geo-eye",
         "historical") %>%
  gather("era","pc", -type)

p <- ggplot(scene, aes(x=type, y=pc, fill = era)) +
  geom_boxplot() +
  theme_minimal() +
  labs(y = "PC 1",
       x = "") +
  theme(legend.title = element_blank(),
        legend.position="bottom",
        text = element_text(size=20)) +
  scale_fill_manual(
    values=c("#999999",
             rgb(255, 173, 70, 100, maxColorValue = 255))) +
  coord_flip()

ggsave("manuscript/figures/foto_bplot_scene.png",
       p,
       width = 7,
       height = 3.5,
       dpi = 150)
