# Also for UNFPA reporting regions

## Directories
getwd()
setwd("C:/GitHub/Country-and-Region-Metadata")


# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "UNFPA_REP_REG_GLOBAL"

library("data.table")
library("countrycode")
source("R/general_functions.R")

# raw input with country names and regions
# this file should contain one row per country and region assignment
dt_in <- setDT(readr::read_csv("raw_data/UNFPA/unfpa_regional_groups_countries.csv", show_col_types = FALSE))

# map common column names to canonical names used below
country_col <- intersect(names(dt_in), c("Country", "country", "Country Name", "Country_Name", "name"))[1]
region_col <- intersect(names(dt_in), c("Region", "region", "Group Name", "Group", "group_name"))[1]
if (is.na(country_col) || is.na(region_col)) {
  stop("Expected country and region columns in raw_data/UNFPA/unfpa_regional_groups_countries.csv")
}
setnames(dt_in, c(country_col, region_col), c("Country", "Region"))

# convert country names to ISO3; keep a small custom map for common edge cases
custom_iso <- c(
  "Kosovo (UNSCR 1244)" = "XKX",
  "Channel Islands" = "CHI",
  "China, Taiwan Province of China" = "TWN"
)
dt_in[, ISO3Code := countrycode::countrycode(Country, origin = "country.name", destination = "iso3c", custom_match = custom_iso)]

# if some names still do not map, report and stop for data cleaning
if (dt_in[is.na(ISO3Code), .N] > 0) {
  print(dt_in[is.na(ISO3Code), unique(Country)])
  stop("Some country names could not be mapped to ISO3Code. Update custom_iso or clean source names.")
}

map_region_code <- c(
  "Arab States Region"                      = "UNFPA_ARAB",
  "Asia and Pacific Region"                 = "UNFPA_EAP",
  "East and Southern Africa Region"         = "UNFPA_ESA",
  "Eastern Europe and Central Asia Region"  = "UNFPA_EECA",
  "Latin American and the Caribbean Region" = "UNFPA_LAC",
  "West and Central Africa Region"          = "UNFPA_WCA"
)

# canonical region labels (stripped of " Region" suffix) for output
map_region_name <- c(
  "Arab States Region"                      = "Arab States",
  "Asia and Pacific Region"                 = "Asia and Pacific",
  "East and Southern Africa Region"         = "East and Southern Africa",
  "Eastern Europe and Central Asia Region"  = "Eastern Europe and Central Asia",
  "Latin American and the Caribbean Region" = "Latin America and Caribbean",
  "West and Central Africa Region"          = "West and Central Africa"
)

dt_in[, Regional_Grouping := parent_code]
dt_in[, Region_Code := map_region_code[Region]]
dt_in[, Region      := map_region_name[Region]]

# stop early if any region name is not in the map
if (dt_in[is.na(Region_Code), .N] > 0) {
  print(dt_in[is.na(Region_Code), unique(Region)])
  stop("Some region names are not in map_region_code. Update the map above.")
}

# join dcname to get M49_Code (same pattern as add.country.name)
dcname <- readRDS("raw_data/SDMX_meta_info/country_name.rds")
dt_in <- dplyr::left_join(dt_in, dcname[, .(id, M49_Code)], by = c("ISO3Code" = "id"))

dt_out <- unique(dt_in[, .(Regional_Grouping, Region, Region_Code, Country, ISO3Code, M49_Code)])
setorder(dt_out, Region, Country)

fwrite(dt_out, "output/UNFPA_REP_REG_GLOBAL.csv")


create.code.book()
bind.all.output()
