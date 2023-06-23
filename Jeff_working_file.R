# JM File

# Libraries ---------------------
library(sf)
library(neonstore)

L3 <- sf::st_read(dsn = "../Data/us_eco_l3.shx")

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

map_tag_table <- neonstore::neon_read("vst_mappingandtagging-basic",site = site_list)
vst_perplotperyear <- neonstore::neon_read("vst_perplotperyear-basic",site = site_list)
allometrics <- read_csv("data_prep/Allometrics.csv") |>
  distinct()

neon_domains <- read_csv("data_prep/neon_domains.csv")

map_tag_table <- map_tag_table %>%
  separate(scientificName, sep = " ", into = c("GENUS", "SPECIES", "Other")) |>
  mutate(taxonID = stringr::str_sub(taxonID, 1,4)) |>
  group_by(individualID) |>
  filter(date == max(date)) |>
  ungroup()



# Import level 3.


# Load NEON


