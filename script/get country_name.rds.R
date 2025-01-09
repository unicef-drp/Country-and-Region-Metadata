dcname <- fread("raw_data/country_name/geographic_areas.csv")
dcname[id == "TUR", name := "Türkiye"]
dcname[id == "CIV", name := "Côte d'Ivoire"]

dcname <- dcname[nchar(id) == 3,.(id, name)]
setnames(dcname, "name", "Country")
saveRDS(dcname, "raw_data/country_name/country_name.rds")
