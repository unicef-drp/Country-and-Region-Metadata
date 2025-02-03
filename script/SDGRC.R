# Also for African Union

# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "SDGRC"

library("data.table")
library("countrycode")
source("R/general_functions.R")

# check another source: 
dt_in <- setDT(readxl::read_xlsx("raw_data/UNECA/Table RECs.xlsx"))
dt_in <- dt_in[!is.na(ISO3)]

setnames(dt_in, "UNECA Subregion", "Region")
dt_in[, table(Region)]

# check: it is the same as SDGRC

# rs <- unique(dt_in$Region)
# dc[, Region:= gsub("ECA_", "", SDGRCRegion1)]
# check.if.same <- function(rs){
#   identical(sort(unique(dt_in[Region == rs, ISO3])), sort(unique(dc[Region == rs, ISO3Code])))
# }
# sapply(rs, check.if.same)

dt_rc <- readxl::read_xlsx("raw_data/SDGRC/9. CompositionOfRegions_RCs_20241202.xlsx", sheet = "Ref_Area_Long")
setDT(dt_rc)[, uniqueN(M49)]

dt_rc[, ISO3Code := countrycode::countrycode(M49, origin = "un", destination = "iso3c")]
dt_rc[is.na(ISO3Code),  ]

# M49                                      Name     Ref_Area_Type           RC_Region RC_UNSDCode
# 1: 736                            Sudan [former]       3.0-Country        ESCAP_AFRICA       98405
# 2: 577            Africa not elsewhere specified 4.0-Not-specified        ESCAP_AFRICA       98405
# 3: 530                      Netherlands Antilles       3.0-Country ESCAP_LATIN_AMERICA       98424
# 4: 830                           Channel Islands       3.0-Country        ESCAP_EUROPE       98423
# 5: 891            Serbia and Montenegro [former]       3.0-Country        ESCAP_EUROPE       98423
# 6: 412                                    Kosovo       3.0-Country        ESCAP_EUROPE       98423
# 7: 890                       Yugoslavia [former]       3.0-Country        ESCAP_EUROPE       98423
# 8: 158 Other non-specified areas in Eastern Asia       3.0-Country    ESCAP_OTHER_AREA       98426

dcname <- readRDS("raw_data/SDMX_meta_info/country_name.rds")
dcname[!id %in% dt_rc$ISO3Code, ]
# 1: CHI                 Channel Islands
# 2: TWN China, Taiwan Province of China
# 3: XKX             Kosovo (UNSCR 1244)

dt_rc[is.na(ISO3Code), ISO3Code := dplyr::recode(M49, "736" = "SSD", "530" = "ANT", "830" = "CHI", "412" = "XKX")]
dt_rc[is.na(ISO3Code), unique(Name)]
dt_rc[duplicated(dt_rc)]

# Drop:
# [1] "Africa not elsewhere specified"            "Serbia and Montenegro [former]"           
# [3] "Yugoslavia [former]"                       "Other non-specified areas in Eastern Asia"

dt_rc <- dt_rc[!is.na(ISO3Code), ]
dt_rc[, uniqueN(ISO3Code)] # 251

dt_rc <- dplyr::left_join(dt_rc, dcname, by = c("ISO3Code" = "id"))
dt_rc[is.na(Country), Country:= Name]
setnames(dt_rc, c("RC_Region"), c("Region_Code"))
dt_rc[, Region:= gsub(": ", "_", RC_RegionName)]
dt_rc[, Regional_Grouping:= parent_code]

unique(dt_rc[Country!=Name,.(Country, Name)])

# Country <--- we use                                                 Name
# 1:                               United Kingdom United Kingdom of Great Britain and Northern Ireland
# 2:                                United States                             United States of America
# 3:                                 Sint Maarten                            Sint Maarten (Dutch part)
# 4:                          Virgin Islands U.S.                         United States Virgin Islands
# 5:                   Saint Martin (French part)                           Saint Martin (French Part)
# 6: Saint Helena, Ascension and Tristan da Cunha                                         Saint Helena
# 7:                                  South Sudan                                       Sudan [former]
# 8:                          Kosovo (UNSCR 1244)                                               Kosovo
# 9:                            Wallis and Futuna                            Wallis and Futuna Islands

dt_rc <- dt_rc[,.(Regional_Grouping, Region, Region_Code, Country, ISO3Code, RC_UNSDCode)]
setorder(dt_rc, Region, Country)
setnames(dt_rc, "RC_UNSDCode", "UNSD_Code")

dt_rc[, Region_Code := toupper(Region_Code)]
dt_rc[, Region_Code := gsub(" ", "_", Region_Code)]
dt_rc[, Region_Code := gsub("-", "_", Region_Code)]
dt_rc[, Region_Code := paste0(Regional_Grouping, "_", Region_Code)]
dt_rc[, unique(Region_Code)]

dt_rc[duplicated(dt_rc), ]
dt_rc <- unique(dt_rc)
fwrite(dt_rc, "output/SDGRC.csv")


create.code.book()
# 
# ECA_regions <- c("ECA_ALL", "ECA_CA", "ECA_EA", "ECA_NA", "ECA_SA", "ECA_WA")
# dt_rc[Region_Code %in% ECA_regions, table(Region)]

# Region
# ECA_All countries  ECA_Central Africa  ECA_Eastern Africa    ECA_North Africa ECA_Southern Africa     ECA_West Africa 
# 54                   7                  14                   7                  11                  15 

# Also different from M49
# setdiff(sort(unique(dt_rc[Region == "ECA_All countries", ISO3Code])), sort(unique(dc[M49Region1 == "Africa", ISO3Code])))
# setdiff(sort(unique(dt_rc[Region == "ECA_Central Africa", ISO3Code])), sort(unique(dc[M49Region2 == "Middle Africa", ISO3Code])))
# setdiff(sort(unique(dt_rc[Region == "ECA_Eastern Africa", ISO3Code])), sort(unique(dc[M49Region2 == "Eastern Africa", ISO3Code])))
# setdiff(sort(unique(dt_rc[Region == "ECA_North Africa", ISO3Code])), sort(unique(dc[M49Region2 == "Northern Africa", ISO3Code])))
# setdiff(sort(unique(dt_rc[Region == "ECA_Southern Africa", ISO3Code])), sort(unique(dc[M49Region2 == "Southern Africa", ISO3Code])))
# setdiff(sort(unique(dt_rc[Region == "ECA_West Africa", ISO3Code])), sort(unique(dc[M49Region2 == "Western Africa", ISO3Code])))
