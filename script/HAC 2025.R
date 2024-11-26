library("data.table")
dt_lb <- CME.assistant::get.live.birth(2024)
dt_lb[, year := floor(year)]
dt_lb <- dt_lb[sex == "b" & year %in% c(2024, 2025)]
dt_lbw <- dcast(dt_lb, ISO3Code ~ year, value.var = "lb")
setnames(dt_lbw, c("2024", "2025"), c("lb2024", "lb2025"))

workdir <- "D:/OneDrive - UNICEF/Documents - Child Mortality/UN IGME data/update country.info.CME/"

dcHAC <- setDT(readxl::read_xlsx(file.path(workdir, "Country-and-Region-Metadata/raw_data/UNICEF_SP/Provisional HAC 2025 Appeals_for DGCA 21Nov2024.xlsx"),
                              sheet = "HAC 2025 coverage", skip = 1))
setnames(dcHAC, c("Region", "Country", "N", "Type"))
dcHAC <- dcHAC[Type!='Regional']
dcHAC[, iso3 := countrycode::countrycode(Country, origin = "country.name", destination = "iso3c")]
dcHAC <- dcHAC[!is.na(iso3)]
dcHAC[,.N]
dcHAC[, table(Type)]
iso_HAC_2024 <- dcHAC$iso3

dt_lbw[ISO3Code %in% dcHAC$iso3, sum(lb2024)] # 57570251
dt_lbw[ISO3Code %in% dcHAC$iso3, sum(lb2025)] # 57879887

dcHAC_lb <- dplyr::left_join(dcHAC, dt_lbw, by = c("iso3" = "ISO3Code"))
dcHAC_lb[, Region := Region[!is.na(Region)][cumsum(!is.na(Region))]]
writexl::write_xlsx(dcHAC_lb, file.path(workdir, "temp/HAC2025 with live birth.xlsx"))
