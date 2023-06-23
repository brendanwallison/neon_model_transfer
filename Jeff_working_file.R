# JM File

# Libraries ---------------------
library(sf)
library(neonstore)

L3 <- sf::st_read(dsn = "../Data/GIS/us_eco_l3.shx")

mapview::mapview(L3)

# Data Loading ------------------
# Based on https://github.com/frec-3044/land-carbon-template/blob/main/data_prep/biomass_clean_up.R

Sys.setenv("NEONSTORE_HOME" = normalizePath("../Data/NEON/Raw"))
site_list <- c("ORNL", "JERC", "TALL", "OSBS")


# Download Vegetation Structure:
# https://data.neonscience.org/data-products/DP1.10098.001
neonstore::neon_download(product = "DP1.10098.001", site = site_list)


# vegetation structure: Read Data
vst_apparentindividual <- neonstore::neon_read(
  table = "vst_apparentindividual-basic", site = site_list)

# Debug
names(map_tag_table)[!(names(map_tag_table) %in% names(dat_ti))]

map_tag_table <- data.frame()
for(ti in 1:length(site_list)){
  dat_ti <- neonstore::neon_read(table = "vst_mappingandtagging-basic", 
                                 site = site_list[ti])
  dat_ti_sub <- dat_ti[ , which(!(names(dat_ti) %in% c("otherTagID", "otherTagOrg")))]
  map_tag_table <- rbind(map_tag_table, dat_ti_sub)
}
 # <- neonstore::neon_read(table = "vst_mappingandtagging-basic", site = site_list[1])
# map_tag_table <- neonstore::neon_read("vst_mappingandtagging-basic", site = site_list)


vst_perplotperyear <- data.frame()
# Can't run for ORNL?
for(ti in 2:length(site_list)){
  per_ti <- neonstore::neon_read("vst_perplotperyear-basic",
                                  site = site_list[ti])
  # dat_ti_sub <- per_ti[ , which(!(names(dat_ti) %in% c("otherTagID", "otherTagOrg")))]
  map_tag_table <- rbind(map_tag_table, dat_ti_sub)
}

# vst_perplotperyear <- neonstore::neon_read("vst_perplotperyear-basic",site = site_list)

allometrics <- readr::read_csv("../Data/Allometrics.csv") |>
  distinct()

neon_domains <- readr::read_csv("../Data/neon_domains.csv")

??separate

maseparate.sfmap_tag_table <- map_tag_table %>%
  separate(scientificName, sep = " ", into = c("GENUS", "SPECIES", "Other")) |>
  mutate(taxonID = stringr::str_sub(taxonID, 1,4)) |>
  group_by(individualID) |>
  filter(date == max(date)) |>
  ungroup()

trees = vst_apparentindividual %>% filter(growthForm %in% c("multi-bole tree", "single bole tree", "small tree"))
dim(trees)

# Import level 3.


# Load NEON


