library("data.table")

dcname <- readRDS("raw_data/country_name/country_name.rds")

dc_au_input <- setDT(readxl::read_xlsx("raw_data/African Union/AfricanUnion_n_55_subregions.xlsx"))
all(dc_au_input$iso3 %in% dcname $ id)
dc_au_input$iso3[!dc_au_input$iso3 %in% dcname $id]

# ESH  Western Sahara

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
dc_au[, Regional_Grouping:= "AU"]
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
setorder(dc_au, Region_Code, Country)

head(dc_au)
fwrite(dc_au, "output/African Union/AU_5regions.csv")

