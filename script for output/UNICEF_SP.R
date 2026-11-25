# the "parent" code should align with data warehouse sdmx meta info
parent_code <- "UNICEF_SP_REG_GLOBAL"
# Humanitarian and High Burdan Countries 

library("data.table")
library("countrycode")
source("R/general_functions.R")

dc <- fread("raw_data/internal/country.info.CME.csv")
dc[, table(SPhumanitarian)]
dc[, table(SPhighburden)]

dtsp1 <- dc[SPhumanitarian == "Humanitarian",.(ISO3Code, SPhumanitarian)]
setnames(dtsp1, "SPhumanitarian", "Region")
dtsp1[, Region_Code := "UNICEF_SP_HUMANITARIAN"]

dtsp2 <- dc[SPhighburden == "High burden",.(ISO3Code, SPhighburden)]
setnames(dtsp2, "SPhighburden", "Region")
dtsp2[, Region_Code := "UNICEF_SP_HIGHBURDEN"]

dtsp <- rbindlist(list(dtsp1, dtsp2))
dtsp[, Regional_Grouping := parent_code]
dtsp <- add.country.name(dtsp)
fwrite(dtsp, "output/UNICEF_SP_REG_GLOBAL.csv")

create.code.book()
