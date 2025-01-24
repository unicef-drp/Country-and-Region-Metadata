# general functions

# add country names and format data

add.country.name <- function(dc, dcname){
  dcname <- readRDS("raw_data/SDMX_meta_info/country_name.rds")
  stopifnot("ISO3Code" %in% colnames(dc))
  dc <- dplyr::left_join(dc, dcname, by = c("ISO3Code" = "id"))
  dc <- dc[,.(Regional_Grouping, Region, Region_Code, Country, ISO3Code)]
  setorder(dc, Region, Country)
  return(dc)
}