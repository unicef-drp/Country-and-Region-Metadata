# FAO regions 

# The source of FAO regions is FAOSTAT
# download csv from Country Group on:
# https://https://www.fao.org/faostat/en/#definitions

getwd()
#setwd("C:/Users/jconkle/Documents/GitHub/Country-and-Region-Metadata/")

# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "FAO_GLOBAL"

library("data.table")
library("countrycode")
source("R/general_functions.R")


dt_meta <- get.sdmx()
dt_meta_FAO <- dt_meta[parent == parent_code]
sdmx_names <- dt_meta[parent == parent_code, name]

# download from FAO file
dt_in <- fread("raw_data/FAO/FAOSTAT_data_7-24-2025.csv")
setnames(dt_in, "ISO3 Code", "ISO3Code")
unique(dt_in$`Country Group`) # 

# 
dtr_level1 <- dt_in[`Country Group` != "",.(ISO3Code, `Country Group` , `Country Group Code` , `Group M49 Code` , `M49 Code` , Country )]
setnames(dtr_level1, "Country Group", "Region")
setnames(dtr_level1, "Country Group Code", "FAO_CODE")
setnames(dtr_level1, "Group M49 Code", "GROUP_M49_CODE")
setnames(dtr_level1, "M49 Code", "M49_CODE")
setnames(dtr_level1, "Country", "FAO_COUNTRY")

# Keep regions
regions_to_keep <- c("Net Food Importing Developing Countries (NFIDCs)" , 
                     "Low Income Food Deficit Countries (LIFDCs)", "World" )  
dtr_level1 <- dtr_level1[Region %in% regions_to_keep]

dtr_level <- dtr_level1

# SDMX name that needs recode:
SDMX_recode <- c(
  "Low income food deficient countries" = "Low Income Food Deficit Countries (LIFDCs)"
)

sdmx_names <- dplyr::recode(sdmx_names, !!!SDMX_recode)

sdmx_names[!sdmx_names %in% unique(dtr_level$Region)] # none 
unique(dtr_level$Region)[!unique(dtr_level$Region) %in% sdmx_names]  # none 

# remove rows with no ISO3Code
dtr_level[is.na(ISO3Code) | ISO3Code == ""]
dtr_level <- dtr_level[!is.na(ISO3Code) & ISO3Code != ""]
dtr_level <- dtr_level[grepl("^[A-Z]{3}$", ISO3Code)]


# check against country code list --------------------------------------------
dc <- fread("raw_data/internal/country.info.CME.csv")
dc[!ISO3Code %in% dtr_level$ISO3Code, .(ISO3Code, OfficialName)]
# [Check!] iso3 in country.info.CME but not in output: XKX # <- as expect
#check.against.dc(dt_out = dtr_level, dc_col0 = "SDGSimpleRegion1")


# match SDMX id
dt_meta_FAO[, name := dplyr::recode(name, !!!SDMX_recode)]
dt_meta_FAO[!name %in% unique(dtr_level$Region), .(id, name)] # empty is a match

dtr_FAO <- dplyr::left_join(dtr_level, dt_meta_FAO, by = c("Region" = "name"))
dtr_FAO[is.na(id), unique(Region)] # regions that do not match SDMX
setnames(dtr_FAO, "id", "Region_Code")

setDT(dtr_FAO)[, Regional_Grouping := parent_code] # add Regional_Grouping variable from SDMX


# add country names. Format and sort output
add.country.name.FAO <- function(dc, dcname){
  dcname <- readRDS("raw_data/SDMX_meta_info/country_name.rds")
  stopifnot("ISO3Code" %in% colnames(dc))
  dc <- dplyr::left_join(dc, dcname, by = c("ISO3Code" = "id"))
  dc <- dc[,.(Regional_Grouping, Region, Region_Code, Country, ISO3Code, FAO_CODE, GROUP_M49_CODE, M49_CODE, FAO_COUNTRY)]
  setorder(dc, Region, Country)
  return(dc)
}
 
dtr_FAO <- add.country.name.FAO(dtr_FAO)



fwrite(dtr_FAO, "output/FAO_REGION_GLOBAL.csv")

