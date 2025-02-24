# SDG regions 

# The source of SDG regions is UNSD M49
# https://unstats.un.org/unsd/methodology/m49



# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "UNSDG_REGION_GLOBAL"

library("data.table")
library("countrycode")
source("R/general_functions.R")

# YL: I haven't figured out how to pull from API, draft for now

dt_in <- fread("raw_data/UNSDG_REGION_GLOBAL/UNSDG_REGION_GLOBAL.csv")
dt_in <- add.country.name(dt_in)
fwrite(dt_in, "output/UNSDG_REGION_GLOBAL.csv")
