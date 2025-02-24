# UNICEF reporting region

# The source of UNICEF report region is Data & Analytics, DAPM, UNICEF. Download by Daniele from data warehouse
# https://data.unicef.org/regionalclassifications/
# 11 regions in total, except Least developed countries/areas

# Combined regions: 
# Europe and Central Asia  = Eastern Europe and Central Asia + Western Europe
# Sub-Saharan Africa = Eastern and Southern Africa +  West and Central Africa

# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "UNICEF_REP_REG_GLOBAL"

library("data.table")
library("countrycode")
source("R/general_functions.R")

# id                            name description  
# 1:  UNICEF_EAP           East Asia and Pacific  
# 2:  UNICEF_ECA         Europe and Central Asia   = Eastern Europe and Central Asia + Western Europe
# 3:  UNICEF_LAC     Latin America and Caribbean    <<--  # instead of Latin America and the Caribbean
# 4: UNICEF_MENA    Middle East and North Africa  
# 5:   UNICEF_NA                   North America  
# 6:   UNICEF_SA                      South Asia  
# 7:  UNICEF_SSA              Sub-Saharan Africa    = Eastern and Southern Africa +  West and Central Africa
# 8:  UNICEF_XCH           World excluding China  

map_name_to_id <- c(
  "East Asia and Pacific" = "UNICEF_EAP",
  
  "Europe and Central Asia" = "UNICEF_ECA",  "Eastern Europe and Central Asia" = "UNICEF_EECA", "Western Europe" = "UNICEF_WE",
  
  "Latin America and Caribbean" = "UNICEF_LAC",
  "Middle East and North Africa" = "UNICEF_MENA",
  "North America" = "UNICEF_NA",
  "South Asia" = "UNICEF_SA",
  "Sub-Saharan Africa" = "UNICEF_SSA", "Eastern and Southern Africa" = "UNICEF_ESA", "West and Central Africa" = "UNICEF_WCA"
)

dc <- fread("raw_data/internal/country.info.CME.csv")
dc[, table(UNICEFReportRegion1, UNICEFReportRegion2)]

dt_in <- fread("raw_data/UNICEF_REP_REG_GLOBAL/UNICEF_REP_REG_GLOBAL.csv")
dt_in <- add.country.name(dt_in)
all(dt_in$Region %in% dc$UNICEFReportRegion1) # TRUE

dc[!ISO3Code %in% dt_in$ISO3Code, .(ISO3Code, OfficialName)]

# the extra ones not in CME:
dt_extra <-  dt_in[!ISO3Code %in% dc$ISO3Code, ] # "TKL", "VAT"
dt_extra_VAT <- dt_in[ISO3Code == "VAT"]
dt_extra_VAT[, `:=`(Region = "Western Europe", Region_Code = "UNICEF_WE")]

dt_unicef <- melt(dc, id.var = "ISO3Code", measure.vars = c("UNICEFReportRegion1", "UNICEFReportRegion2"), value.name = "Region")[Region!=""]
names(map_name_to_id)[!names(map_name_to_id) %in% unique(dt_unicef$Region)]  # none 
dt_unicef[, Region_Code := map_name_to_id[Region]]
dt_unicef[, variable := NULL]


dt_unicef[, Regional_Grouping := parent_code]
dt_unicef <- add.country.name(dt_unicef)

dt_unicef_all <- rbindlist(list(dt_unicef, dt_extra, dt_extra_VAT))
setorder(dt_unicef_all, Region, Country)
fwrite(dt_unicef_all, "output/UNICEF_REP_REG_GLOBAL.csv")
