# for saving some rds input data

# only run when needed 

library("data.table")
# copy from DW-Production/refs/heads/dev/00_master/010_metadata/geographic_areas/geographic_areas.csv
# dt_sdmx <- fread("...") # copy the raw link
# fwrite(dt_sdmx, "raw_data/SDMX_meta_info/geographic_areas.csv")

dt_M49 <- fread("output/UNSDG/m49_mapping.csv")[,.(UNICEF_code, m49)]
dt_M49_country <- dt_M49[nchar(UNICEF_code)==3]
dt_M49_country[]

dcname <- fread("raw_data/SDMX_meta_info/geographic_areas.csv")
dcname <- dcname[nchar(id) == 3,.(id, name)]
setnames(dcname, "name", "Country")

dcname[!id %in% dt_M49_country$UNICEF_code]
# There are only three, these three won't have M49 code
# 1:    CHI                 Channel Islands
# 2:    TWN China, Taiwan Province of China
# 3:    XKX             Kosovo (UNSCR 1244)

dcname <- dplyr::left_join(dcname, dt_M49_country, by = c("id" = "UNICEF_code"))
setnames(dcname, c("m49"), c("M49_Code"))
saveRDS(dcname, "raw_data/SDMX_meta_info/country_name.rds")


# CME internal country.info for reference
# # As I am checking against CM internal country.info
dc <- CME.assistant::get.country.info.CME(2025)
# remove all columns contain "pop"
dc <- dc[,!grep("pop", colnames(dc), value = TRUE), with = FALSE]
dc[ISO3Code == "RKS", ISO3Code := "XKX"] # Kosovo 
fwrite(dc, "raw_data/internal/country.info.CME.csv")
