# The five African Union regions 

# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "AU"

library("data.table")
source("R/general_functions.R")

dcname <- readRDS("raw_data/SDMX_meta_info/country_name.rds")

dc_au_input <- setDT(readxl::read_xlsx("raw_data/AU/AfricanUnion_n_55_subregions.xlsx"))
all(dc_au_input$iso3 %in% dcname $ id)
dc_au_input$iso3[!dc_au_input$iso3 %in% dcname $id] # except ESH  Western Sahara, which will be included

# Region_Code, Region, Regional_Grouping
# AU_AFRICA	Africa (African Union)		AU
# AU_CENTRAL_AFRICA	Central Africa (African Union)		AU
# AU_EASTERN_AFRICA	Eastern Africa (African Union)		AU
# AU_NORTHERN_AFRICA	Northern Africa (African Union)		AU
# AU_SOUTHERN_AFRICA	Southern Africa (African Union)		AU
# AU_WESTERN_AFRICA	Western Africa (African Union)		AU

dc_au_input_AF <- copy(dc_au_input)
dc_au_input_AF[, region:= "Africa"]

dc_au <- rbindlist(list(dc_au_input, dc_au_input_AF))
dc_au[, Region:= paste(region,  "(African Union)")]
dc_au[, Regional_Grouping:= parent_code]
dc_au[, Region_Code := dplyr::recode(Region, 
                                     "Africa (African Union)" = "AU_AFRICA",
                                     "Central Africa (African Union)" = "AU_CENTRAL_AFRICA",
                                     "Eastern Africa (African Union)" = "AU_EASTERN_AFRICA",
                                     "Northern Africa (African Union)" = "AU_NORTHERN_AFRICA",
                                     "Southern Africa (African Union)" = "AU_SOUTHERN_AFRICA",
                                     "Western Africa (African Union)" = "AU_WESTERN_AFRICA")]
dc_au[is.na(Region_Code)]
dc_au <- dplyr::left_join(dc_au, dcname, by = c("iso3" = "id"))
dc_au[is.na(Country), Country := name]
setnames(dc_au, "iso3", "ISO3Code")
dc_au <- dc_au[,.(Regional_Grouping, Region, Region_Code, Country, ISO3Code)]
head(dc_au)
table(dc_au$Region)

# Africa (African Union)  Central Africa (African Union)  Eastern Africa (African Union) 
# 55                               9                              14 
# Northern Africa (African Union) Southern Africa (African Union)  Western Africa (African Union) 
# 7                              10                              15 
# 

setorder(dc_au, Region_Code, Country)

head(dc_au)
fwrite(dc_au, "output/AU.csv")

