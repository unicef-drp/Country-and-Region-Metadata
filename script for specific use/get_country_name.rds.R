# for saving some rds data

library("data.table")
# copy from DW-Production/refs/heads/dev/00_master/010_metadata/geographic_areas/geographic_areas.csv
# dt_sdmx <- fread("...") # copy the raw link
# fwrite(dt_sdmx, "raw_data/SDMX_meta_info/geographic_areas.csv")

dcname <- fread("raw_data/SDMX_meta_info/geographic_areas.csv")

dcname <- dcname[nchar(id) == 3,.(id, name)]
setnames(dcname, "name", "Country")
saveRDS(dcname, "raw_data/SDMX_meta_info/country_name.rds")


# CME internal country.info for reference
# # As I am checking against CM internal country.info
dc <- CME.assistant::get.country.info.CME(2025)
# remove all columns contain "pop"
dc <- dc[,!grep("pop", colnames(dc), value = TRUE), with = FALSE]
dc[ISO3Code == "RKS", ISO3Code := "XKX"] # Kosovo 
fwrite(dc, "raw_data/internal/country.info.CME.csv")
