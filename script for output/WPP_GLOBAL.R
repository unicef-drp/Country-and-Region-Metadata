# WPP Global - list of countries that have population data 

# The source of WPP Global is UN Dept of Economic Affairs Population Division
# csv files from World Population Prospects at:
# https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=CSV%20format
# This script downloads directly from the website 

getwd()
#setwd("C:/Users/jconkle/Documents/GitHub/Country-and-Region-Metadata/")

# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "WPP_GLOBAL"

library("data.table")
library("countrycode")
source("R/general_functions.R")


dt_meta <- get.sdmx()
dt_meta_WPP <- dt_meta[parent == parent_code]
sdmx_names <- dt_meta[parent == parent_code, name]

# download from website
url <- "https://population.un.org/wpp/assets/Excel%20Files/1_Indicator%20(Standard)/CSV_FILES/WPP2024_TotalPopulationBySex.csv.gz"
dt_in <- fread(url)

dt_in <- dt_in[, .(ISO3_code, LocID, SDMX_code, Location)]

setnames(dt_in, "ISO3_code", "ISO3Code")

# Keep only rows where ISO3Code is not missing
dt_in <- dt_in[!is.na(ISO3Code) & ISO3Code != ""]

# Collapse to one row per ISO3Code (remove duplicates)
dt_in <- unique(dt_in, by = "ISO3Code")

dt_in[, REF_AREA := "World"]

# 
dtr_level1 <- dt_in[REF_AREA != "",.(ISO3Code, SDMX_code , REF_AREA , Location )]
setnames(dtr_level1, "REF_AREA", "Region")
setnames(dtr_level1, "SDMX_code", "M49_CODE")
setnames(dtr_level1, "Location", "WPP_COUNTRY")

dtr_level <- dtr_level1

# check against country code list --------------------------------------------
dc <- fread("raw_data/internal/country.info.CME.csv")
dc[!ISO3Code %in% dtr_level$ISO3Code, .(ISO3Code, OfficialName)]
# [Check!] iso3 in country.info.CME but not in output: XKX # <- as expect
#check.against.dc(dt_out = dtr_level, dc_col0 = "SDGSimpleRegion1")


# match SDMX id
dt_meta_WPP[, name := dplyr::recode(name, !!!SDMX_recode)]
dt_meta_WPP[!name %in% unique(dtr_level$Region), .(id, name)] # empty is a match

dtr_WPP <- dplyr::left_join(dtr_level, dt_meta_WPP, by = c("Region" = "name"))
dtr_WPP[is.na(id), unique(Region)] # regions that do not match SDMX
setnames(dtr_WPP, "id", "Region_Code")

setDT(dtr_WPP)[, Regional_Grouping := parent_code] # add Regional_Grouping variable from SDMX


# add country names. Format and sort output
add.country.name.WPP <- function(dc, dcname){
  dcname <- readRDS("raw_data/SDMX_meta_info/country_name.rds")
  stopifnot("ISO3Code" %in% colnames(dc))
  dc <- dplyr::left_join(dc, dcname, by = c("ISO3Code" = "id"))
  dc <- dc[,.(Regional_Grouping, Region, Country, ISO3Code, M49_CODE, WPP_COUNTRY)]
  setorder(dc, Region, Country)
  return(dc)
}

dtr_WPP <- add.country.name.WPP(dtr_WPP)



fwrite(dtr_WPP, "output/WPP_GLOBAL.csv")

