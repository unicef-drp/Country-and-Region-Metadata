# for saving some rds data

library("data.table")
# dt_sdmx <- fread("https://raw.githubusercontent.com/unicef-drp/DW-Production/refs/heads/dev/00_master/010_metadata/geographic_areas/geographic_areas.csv?token=GHSAT0AAAAAAC5OGJMWTORN4CN52DP33Y6GZ4VV74A")
# fwrite(dt_sdmx, "raw_data/SDMX_meta_info/geographic_areas.csv")

dcname <- fread("raw_data/SDMX_meta_info/geographic_areas.csv")

dcname <- dcname[nchar(id) == 3,.(id, name)]
setnames(dcname, "name", "Country")
saveRDS(dcname, "raw_data/SDMX_meta_info/country_name.rds")
