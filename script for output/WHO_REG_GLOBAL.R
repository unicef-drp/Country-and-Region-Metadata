# WHO Region WHO_REG_GLOBAL

# (see bottom of this page:
# https://www.who.int/news/item/24-05-2025-seventy-eighth-world-health-assembly---daily-update--24-may-2025
# The resolution at https://apps.who.int/gb/ebwha/pdf_files/WHA78/A78_31-en.pdf

# 200 countries? please double-check


# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "WHO_REG_GLOBAL"

library("data.table")
library("countrycode")
source("R/general_functions.R")
  
# 
dc <- fread("raw_data/internal/country.info.CME.csv")
dc[, table(WHORegion1)]
dc[ISO3Code == "RKS", ISO3Code := "XKX"] # Kosovo


# WHO_AFRO	Africa
# WHO_AMRO	Americas
# WHO_EMRO	Eastern Mediterranean
# WHO_EURO	Europe
# WHO_SEARO	Southeast Asia
# WHO_WPRO	Western Pacific

map_name_to_id <- c(
  "Africa" = "WHO_AFRO",
  "Americas" = "WHO_AMRO",
  "Eastern Mediterranean" = "WHO_EMRO",
  "Europe" = "WHO_EURO",
  "South-East Asia"  = "WHO_SEARO",
  "Western Pacific" = "WHO_WPRO"
)

dc[, Region:= WHORegion1]
dt_WHO <- dc[WHORegion1!="",.(ISO3Code, Region)]

names(map_name_to_id)[!names(map_name_to_id) %in% unique(dt_WHO$Region)]  # none 
dt_WHO[, Region_Code := map_name_to_id[Region]]
dt_WHO[, Regional_Grouping := parent_code]
dt_WHO <- add.country.name(dt_WHO)

setorder(dt_WHO, Region, Country)
fwrite(dt_WHO, "output/WHO_REG_GLOBAL.csv")
