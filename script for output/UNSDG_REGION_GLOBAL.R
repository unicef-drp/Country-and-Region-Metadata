# SDG regions 

# The source of SDG regions is UNSD M49
# download csv from 
# https://unstats.un.org/unsd/methodology/m49/overview/
# https://unstats.un.org/sdgs/indicators/regional-groups/


# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "UNSDG_REGION_GLOBAL"

library("data.table")
library("countrycode")
source("R/general_functions.R")

dt_meta <- get.sdmx()
dt_meta_SDG <- dt_meta[parent == parent_code]
sdmx_names <- dt_meta[parent == parent_code, name]

# download from m49/overview/
dt_in <- fread("raw_data/UNSDG_REGION_GLOBAL/UNSD — Methodology.csv")
setnames(dt_in, "ISO-alpha3 Code", "ISO3Code")
unique(dt_in$`Region Name`) # 5 # Africa, Americas, Asia, Europe, Oceania 
unique(dt_in$`Sub-region Name`) # 18
unique(dt_in$`Intermediate Region Name`) # 8

# # Africa, Americas, Asia, Europe, Oceania, <- only need Oceania
dtr_level1 <- dt_in[`Region Name` != "",.(ISO3Code, `Region Name`)]
setnames(dtr_level1, "Region Name", "Region")

dtr_level2 <- dt_in[`Sub-region Name`!="",.(ISO3Code, `Sub-region Name`)]
setnames(dtr_level2, "Sub-region Name", "Region")

dtr_level3 <- dt_in[`Intermediate Region Name`!="",.(ISO3Code, `Intermediate Region Name`)]
setnames(dtr_level3, "Intermediate Region Name", "Region")

# extra
dtrLDC <- dt_in[`Least Developed Countries (LDC)`=="x", .(ISO3Code, `Least Developed Countries (LDC)`)]
dtrLDC[, Region := "Least Developed Countries (LDC)"]
dtrLDC <- dtrLDC[, .(ISO3Code, Region)]

dtr_LLDC <- dt_in[`Land Locked Developing Countries (LLDC)`=="x", .(ISO3Code, `Land Locked Developing Countries (LLDC)`)]
dtr_LLDC[, Region := "Landlocked developing countries (LLDC)"]
dtr_LLDC <- dtr_LLDC[, .(ISO3Code, Region)]

dtr_SIDS <- dt_in[`Small Island Developing States (SIDS)`=="x", .(ISO3Code, `Small Island Developing States (SIDS)`)]
dtr_SIDS[, Region := "Small island developing States (SIDS)"]
dtr_SIDS <- dtr_SIDS[, .(ISO3Code, Region)]

dtr_level <- rbindlist(list(dtr_level1, dtr_level2, dtr_level3, dtrLDC, dtr_LLDC, dtr_SIDS))


# binding regions ------------------------------------------------------------
# 
# 1:        Central and Southern Asia                   Southern Asia
# 2:        Central and Southern Asia                    Central Asia
# 3:   Eastern and South-Eastern Asia              South-Eastern Asia
# 4:   Eastern and South-Eastern Asia                    Eastern Asia
# 5:      Europe and Northern America                 Southern Europe
# 6:      Europe and Northern America                  Western Europe
# 7:      Europe and Northern America                  Eastern Europe
# 8:      Europe and Northern America                Northern America
# 9:      Europe and Northern America                 Northern Europe
# 11: Northern Africa and Western Asia                    Western Asia
# 12: Northern Africa and Western Asia                 Northern Africa

# 15: Oceania (exc. Australia and New Zealand)                       Polynesia
# 16: Oceania (exc. Australia and New Zealand)                       Melanesia
# 17: Oceania (exc. Australia and New Zealand)                      Micronesia

dtrb1 <- dtr_level[Region %in% c("Southern Asia", "Central Asia"), ]
dtrb1[, Region := "Central and Southern Asia"]

dtrb2 <- dtr_level[Region %in% c("South-eastern Asia", "Eastern Asia"), ]
dtrb2[, Region := "Eastern and South-Eastern Asia"]

dtrb3 <- dtr_level[Region %in% c("Southern Europe", "Western Europe", "Eastern Europe", "Northern America", "Northern Europe"), ]
dtrb3[, Region := "Europe and Northern America"]

dtrb4 <- dtr_level[Region %in% c("Western Asia", "Northern Africa"), ]
dtrb4[, Region := "Northern Africa and Western Asia"]

dtrb5 <- dtr_level[Region %in% c("Polynesia", "Melanesia", "Micronesia"), ]
dtrb5[, Region := "Oceania (exc. Australia and New Zealand)"]



dtr_level <- unique(rbindlist(list(dtr_level, dtrb1, dtrb2, dtrb3, dtrb4, dtrb5)))


# SDMX name that needs recode:
SDMX_recode <- c(
  "South-Eastern Asia" = "South-eastern Asia" ,
  "North America" = "Northern America",
  "Oceania, excluding Australia and New Zealand" = "Oceania (exc. Australia and New Zealand)",
  "Least developed countries" = "Least Developed Countries (LDC)",
  "Landlocked developing countries (LLDCs)" = "Landlocked developing countries (LLDC)",
  "Small Island Developing States (SIDS)" = "Small island developing States (SIDS)"
)
sdmx_names <- dplyr::recode(sdmx_names, !!!SDMX_recode)

sdmx_names[!sdmx_names %in% unique(dtr_level$Region)] # none 
unique(dtr_level$Region)[!unique(dtr_level$Region) %in% sdmx_names]  # none 
# # "Oceania" "Eastern Asia" "Western Asia" "Northern Africa" "Southern Africa" "Central Asia" "South-Eastern Asia" "Western Europe" "Eastern Europe" "Northern America"
# [1] "Africa"          "Americas"        "Asia"            "Northern Europe" "Southern Europe" "Western Europe" 
# [7] "Micronesia" 

dtr_level[is.na(ISO3Code) | ISO3Code == ""]
dtr_level <- dtr_level[!is.na(ISO3Code) & ISO3Code != ""]

# check against country code list --------------------------------------------
dc <- fread("raw_data/internal/country.info.CME.csv")
dc[!ISO3Code %in% dtr_level$ISO3Code, .(ISO3Code, OfficialName)]
check.against.dc(dt_out = dtr_level, dc_col0 = "SDGSimpleRegion1")
# [Check!] iso3 in country.info.CME but not in output: XKX # <- as expect

dc_recode <- c(
  "South-Eastern Asia" = "South-eastern Asia",
  "Least developed countries" = "Least Developed Countries (LDC)"
)

dc[, SDGSimpleRegion2 := dplyr::recode(SDGSimpleRegion2, !!!dc_recode)]
dc[, SDGSimpleRegion3 := dplyr::recode(SDGSimpleRegion3, !!!dc_recode)]
dc[, SDGRegion3 := dplyr::recode(SDGRegion3, !!!dc_recode)]
dc[, M49Region2 := dplyr::recode(M49Region2, !!!dc_recode)]
check.against.dc(dt_out = dtr_level, dc_col0 = "SDGSimpleRegion2")
check.against.dc(dt_out = dtr_level, dc_col0 = "SDGSimpleRegion3")

check.against.dc(dt_out = dtr_level, dc_col0 = "SDGRegion1")
check.against.dc(dt_out = dtr_level, dc_col0 = "SDGRegion2")
check.against.dc(dt_out = dtr_level, dc_col0 = "SDGRegion3")

check.against.dc(dt_out = dtr_level, dc_col0 = "M49Region1")
check.against.dc(dt_out = dtr_level, dc_col0 = "M49Region2")
check.against.dc(dt_out = dtr_level, dc_col0 = "M49Region3")

# match SDMX id
dt_meta_SDG[, name := dplyr::recode(name, !!!SDMX_recode)]
dt_meta_SDG[!name %in% unique(dtr_level$Region), .(id, name)]

dtr_SDG <- dplyr::left_join(dtr_level, dt_meta_SDG, by = c("Region" = "name"))
dtr_SDG[is.na(id), unique(Region)]
setnames(dtr_SDG, "id", "Region_Code")

setDT(dtr_SDG)[, Regional_Grouping := parent_code]
dtr_SDG <- add.country.name(dtr_SDG)

# add M49 code 
dt_M49 <- fread("output/UNSDG/m49_mapping.csv")[,.(UNICEF_code, m49)]
setnames(dt_M49, c("UNICEF_code", "m49"), c("Region_Code", "M49Region_Code"))
dtr_SDG[!Region_Code %in% dt_M49$Region_Code, .(Region_Code, Region)] # none 
dtr_SDG <- dplyr::left_join(dtr_SDG, dt_M49, by = "Region_Code")

dtr_SDG <- dtr_SDG[,.(Regional_Grouping, Region, Region_Code, M49Region_Code, Country, ISO3Code, M49_Code)]
fwrite(dtr_SDG, "output/UNSDG_REGION_GLOBAL.csv")


create.code.book()
dtall <- bind.all.output()
