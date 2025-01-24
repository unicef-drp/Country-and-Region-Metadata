# UNICEF_PROG_REG_GLOBAL
# Please use R project to get the correct working directory

# the "parent" code from data warehouse sdmx meta info
parent_code <- "UNICEF_PROG_REG_GLOBAL"

library("data.table")

source("R/general_functions.R")

# raw input
dt1 <- setDT(readxl::read_xlsx(file.path("raw_data/UNICEF_PROG_REG_GLOBAL/UNICEF Programme Countries and Territories.xlsx")))

# data warehouse info
dtr_code <- fread("raw_data/SDMX_meta_info/geographic_areas.csv")
dtr_code <- dtr_code[parent == parent_code]

setnames(dt1, "ISO3 Code", "ISO3Code")
setnames(dt1, "Region", "UNICEF_Programme_Region")
uniqueN(dt1$ISO3Code) # 158 # there are 158 countries in the UNICEF programming
dt1[`Country Territory and Location` %like% "Kosovo" ,  ]

rs <- c(
  "EAPR" = "East Asia and Pacific", # In A: Brunei Darussalam, In A:  Republic of Korea, In A:  Singapore"
  "ECAR" = "Europe and Central Asia", # A:  Russian Federation"
  "ESAR" = "Eastern and Southern Africa", # In A:  Mauritius, In A:  Seychelles"
  "LACR" = "Latin America and the Caribbean", # "In A:  Bahamas"
  "MENAR"= "Middle East and North Africa", # same
  "SAR"  = "South Asia",# same
  "WCAR" = "West and Central Africa"# same
)
dt1[, Region:= dplyr::recode(UNICEF_Programme_Region, !!!rs)]
stopifnot(all(unique(dt1$Region) %in% dtr_code $ name))
setnames(dtr_code, c("id", "parent"), c("Region_Code", "Regional_Grouping"))

dt1 <- dplyr::left_join(dt1, dtr_code, by = c("Region" = "name"))

dt_final <- add.country.name(dt1)

fwrite(dt_final, file.path("output", paste0(parent_code, ".csv")))


