# for saving some rds data

library("data.table")
# copy from DW-Production/refs/heads/dev/00_master/010_metadata/geographic_areas/geographic_areas.csv
# dt_sdmx <- fread("...") # copy the raw link
# fwrite(dt_sdmx, "raw_data/SDMX_meta_info/geographic_areas.csv")

dcname <- fread("raw_data/SDMX_meta_info/geographic_areas.csv")

dcname <- dcname[nchar(id) == 3,.(id, name)]
setnames(dcname, "name", "Country")
saveRDS(dcname, "raw_data/SDMX_meta_info/country_name.rds")
