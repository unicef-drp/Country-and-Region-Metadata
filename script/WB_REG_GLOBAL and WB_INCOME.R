# WB regions
# 

# the "parent" code aligns with data warehouse sdmx meta info
parent_code1 <- "WB_REG_GLOBAL"
parent_code2 <- "WB_INCOME"


library("data.table")
library("countrycode")
source("R/general_functions.R")

# WB regions

dtwb <- setDT(readxl::read_xlsx(file.path("raw_data/WB_REG_GLOBAL/CLASS_WB_FY2025.xlsx"), n_max = 218))
setnames(dtwb, "Code", "ISO3Code")

dc <- fread("raw_data/internal/country.info.CME.csv")
dc[, unique(WBRegion1)]
# [1] "South Asia"                      "Sub-Saharan Africa"              ""                               
# [4] "Europe and Central Asia"         "Middle East and North Africa"    "Latin America and the Caribbean"
# [7] "East Asia and Pacific"           "North America"  


dtwb_reg <- dtwb[,.(ISO3Code, Region)]
unique(dtwb_reg$Region)
# [1] "South Asia"                 "Europe & Central Asia"      "Middle East & North Africa"
# [4] "East Asia & Pacific"        "Sub-Saharan Africa"         "Latin America & Caribbean" 
# [7] "North America"  

dtwb_reg[, Region := gsub("&", "and", Region)]
region_name_recode = c("Latin America and Caribbean" = "Latin America and the Caribbean")
dtwb_reg[, Region := dplyr::recode(Region, !!!region_name_recode)]
unique(dtwb_reg$Region)[!unique(dtwb_reg$Region) %in% dc$WBRegion1] # none 

id_projection <- c(
  "East Asia and Pacific" = "WB_EAP",
  "Latin America and the Caribbean" = "WB_LAC",
  "Middle East and North Africa" = "WB_MNA",
  "North America" = "WB_NAR",
  "South Asia" = "WB_SAR",
  "Sub-Saharan Africa" = "WB_SSA",
  "Europe and Central Asia" = "WB_ECA" # new , not in dw yet
)

unique(dtwb_reg$Region)[!unique(dtwb_reg$Region) %in% names(id_projection)] #none

# id                            name description        parent
# 1: WB_EAP           East Asia and Pacific          NA WB_REG_GLOBAL
# 2: WB_LAC Latin America and the Caribbean          NA WB_REG_GLOBAL
# 3: WB_MNA    Middle East and North Africa          NA WB_REG_GLOBAL
# 4: WB_NAR                   North America          NA WB_REG_GLOBAL
# 5: WB_SAR                      South Asia          NA WB_REG_GLOBAL
# 6: WB_SSA              Sub-Saharan Africa          NA WB_REG_GLOBAL

dtwb_reg[, Region_Code := id_projection[Region]]

dt_meta <- get.sdmx()
dt_meta[parent == parent_code1, ]
dc$ISO3Code[!dc$ISO3Code%in%dtwb$ISO3Code] # "COK" "NIU" "AIA" "MSR" are not WB countries
dtwb$ISO3Code[!dtwb$ISO3Code%in%dc$ISO3Code] # a lot
dc[WBRegion4=="", unique(ISO3Code)]    # "VEN" is not classified this year

dtwb_reg[, Regional_Grouping := parent_code1]
dtwb_reg <- add.country.name(dtwb_reg)
check.against.dc(dt_out = dtwb_reg, dc_col0 = "WBRegion1")
fwrite(dtwb_reg, "output/WB_REG_GLOBAL.csv")

# WB income
dtwb_income <- dtwb[,.(ISO3Code, `Income group`)]
setnames(dtwb_income, "Income group", "Region")
unique(dtwb_income$Region)
dt_meta[parent == parent_code2, ]
# id                             name description    parent
# 1:  WB_HI         World Bank (high income)          NA WB_INCOME
# 2:  WB_LI          World Bank (low income)          NA WB_INCOME
# 3: WB_LMI World Bank (lower middle income)          NA WB_INCOME
# 4: WB_UMI World Bank (upper middle income)          NA WB_INCOME

recode_id_to_name <- c(
  "WB_HI" = "World Bank (high income)",
  "WB_LI" = "World Bank (low income)",
  "WB_LMI" = "World Bank (lower middle income)",
  "WB_UMI" = "World Bank (upper middle income)"
)

table(dc$WBRegion4)
table(dtwb_income$Region)
# High income          Low income Lower middle income Upper middle income 
# 86                  26                  51                  54 
check.against.dc(dt_out = dtwb_income, dc_col0 = "WBRegion4")

recode_region_name <- c(
  "High income" = "WB_HI",
  "Low income" = "WB_LI",
  "Lower middle income" = "WB_LMI",
  "Upper middle income" = "WB_UMI"
)

dtwb_income[is.na(Region)]
# ISO3Code Region
# 1:      VEN   <NA>
dtwb_income <- dtwb_income[!is.na(Region)]
dtwb_income[, Region_Code := dplyr::recode(Region, !!!recode_region_name)]
dtwb_income[, Region := dplyr::recode(Region_Code, !!!recode_id_to_name)]
dtwb_income[, Regional_Grouping := parent_code2]
dtwb_income <- add.country.name(dtwb_income)
fwrite(dtwb_income, "output/WB_INCOME.csv")
