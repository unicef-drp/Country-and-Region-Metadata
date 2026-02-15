# script to produce UNICEF_NT grouping output

# UNICEF Nutrition Targets (NT) groupings

# The source of UNICEF NT data includes:
# - UNICEF_NT_VAS.csv: Vitamin A Supplementation Priority countries

getwd()
#setwd("C:/Users/jconkle/Documents/GitHub/Country-and-Region-Metadata/")

# no single parent_code since we're combining multiple groupings

library("data.table")
source("R/general_functions.R")

# Read UNICEF NT raw data file
dt_vas <- fread("raw_data/UNICEF_NT/UNICEF_NT_VAS.csv")

# Verify structure
head(dt_vas)
uniqueN(dt_vas$ISO3Code) 
unique(dt_vas$Region)
unique(dt_vas$Regional_Grouping)

# Add country names and format output
dt_final <- add.country.name(dt_vas)

# Output to file
fwrite(dt_final, "output/UNICEF_NT.csv")

create.code.book()
bind.all.output()