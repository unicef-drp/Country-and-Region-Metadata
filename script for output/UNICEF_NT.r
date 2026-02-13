# script to produce UNICEF_NT grouping output

# UNICEF Nutrition Targets (NT) groupings

# The source of UNICEF NT data includes:
# - UNICEF_NT_VAS.csv: Vitamin A Supplementation Priority countries
# - UNICEF_SOWC.csv: State of the World's Children data

getwd()
#setwd("C:/Users/jconkle/Documents/GitHub/Country-and-Region-Metadata/")

# no single parent_code since we're combining multiple groupings

library("data.table")
source("R/general_functions.R")

# Read UNICEF NT raw data files
dt_vas <- fread("raw_data/UNICEF_NT/UNICEF_NT_VAS.csv")
dt_sowc <- fread("raw_data/UNICEF_NT/UNICEF_SOWC.csv")

# Combine both datasets
dt_combined <- rbindlist(list(dt_vas, dt_sowc))

# Verify structure
head(dt_combined)
uniqueN(dt_combined$ISO3Code) 
unique(dt_combined$Region)
unique(dt_combined$Regional_Grouping)

# Add country names and format output
dt_final <- add.country.name(dt_combined)

# Output to file
fwrite(dt_final, "output/UNICEF_NT.csv")

