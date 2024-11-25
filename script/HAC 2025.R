library("data.table")
dt_lb <- CME.assistant::get.live.birth(2024)
dt_lb <- dt_lb[sex == "b" & year == 2024.5]

dc <- setDT(readxl::read_xlsx("D:/OneDrive - UNICEF/Documents - Child Mortality/UN IGME data/update country.info.CME/Regional Groupings/2024/UNICEF Programme Countries and Territories.xlsx"))

dc[, `:=`(HAC = `2023 Countries with Stand-alone HACs or Multi-country HACs with ORE over 50%`, 
          Humanitarian = `Humanitarian countries for impact and outcome indicators`)]

iso_HAC_2023 <- dc[HAC == "Yes", `ISO3 Code`]
dt_lb[ISO3Code %in% dc[HAC == "Yes", `ISO3 Code`], sum(lb)]
dt_lb[ISO3Code %in% dc[Humanitarian == "Yes", `ISO3 Code`], sum(lb)]

lbtotal <- sum(dt_lb$lb)

dcHAC <- setDT(readxl::read_xlsx("D:/OneDrive - UNICEF/Documents - Child Mortality/UN IGME data/update country.info.CME/Regional Groupings/2024/Provisional HAC 2025 Appeals_for DGCA 21Nov2024.xlsx",
                              sheet = "HAC 2025 coverage", skip = 1))
setnames(dcHAC, c("Region", "Country", "N", "Type"))
dcHAC <- dcHAC[Type!='Regional']
dcHAC[, iso3 := countrycode::countrycode(Country, origin = "country.name", destination = "iso3c")]
dcHAC <- dcHAC[!is.na(iso3)]
dcHAC[,.N]
dcHAC[, table(Type)]
iso_HAC_2024 <- dcHAC$iso3
setdiff(iso_HAC_2024, iso_HAC_2023)

countrycode::countrycode(setdiff(iso_HAC_2023, iso_HAC_2024), origin = "iso3c", destination = "country.name")
countrycode::countrycode(setdiff(iso_HAC_2024, iso_HAC_2023), origin = "iso3c", destination = "country.name")

dt_lb[ISO3Code %in% dcHAC$iso3, sum(lb)] # 57570251

dcHAC <- dplyr::left_join(dcHAC, dt_lb[, .(ISO3Code, lb)], by = c("iso3" = "ISO3Code"))
setnames(dcHAC, "lb", "lb2024")
dcHAC[, Region := Region[!is.na(Region)][cumsum(!is.na(Region))]]
writexl::write_xlsx(dcHAC, "HAC2024 with live birth.xlsx")
