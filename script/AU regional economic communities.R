# Regional Economic Communities (RECs) for African Union aggregation
# data source:
# https://au.int/en/organs/recs

library(data.table)
dir_project <- here::here() # Set the working directory to Country-and-Region-Metadata



# Create the data frame
dt_rec <- data.table(
  Region = c(
    rep("Arab Maghreb Union (UMA)", 5), # 1
    
    rep("Common Market for Eastern and Southern Africa (COMESA)", 21), # 2 # https://www.comesa.int/members/ (added 2)
    rep("Community of Sahel-Saharan States (CEN-SAD)", 29), # 3 # https://en.wikipedia.org/wiki/Community_of_Sahel%E2%80%93Saharan_States
    rep("East African Community (EAC)", 8), # 1 # https://www.eac.int/eac-partner-states (added 3)
   
    rep("Economic Community of Central African States (ECCAS)", 11), # 4  # https://ceeac-eccas.org/en/
    rep("Economic Community of West African States (ECOWAS)", 15), # 5 # https://www.ecowas.int/member-states/ 
    rep("Intergovernmental Authority on Development (IGAD)", 8), # 4
    
    rep("Southern African Development Community (SADC)", 16) # 5  # https://www.sadc.int/member-states (added 1)
  ),
  Country = c(
    # UMA
    "Algeria", "Libya", "Mauritania", "Morocco", "Tunisia",
    # COMESA
    "Burundi", "Comoros", "Democratic Republic of the Congo", "Djibouti", "Egypt", "Eritrea", "Ethiopia", "Eswatini",
    "Kenya", "Libya", "Madagascar", "Malawi", "Mauritius", "Rwanda", "Seychelles",
    "Somalia", "Sudan",  "Tunisia",  "Uganda", "Zambia", "Zimbabwe",
    # CEN-SAD (29 countries corrected)
    "Benin", "Burkina Faso", "Cabo Verde", "Central African Republic", "Chad",
    "Comoros", "Côte d’Ivoire", "Djibouti", "Egypt", "Eritrea", "Gambia",
    "Ghana", "Guinea", "Guinea Bissau", "Kenya", "Liberia", "Libya", "Mali",
    "Mauritania", "Morocco", "Niger", "Nigeria", "São Tomé and Príncipe",
    "Senegal", "Sierra Leone", "Somalia", "Sudan", "Togo", "Tunisia",
    # EAC
    "Democratic Republic of the Congo",
    "Burundi", "Kenya", "Rwanda", "Somalia",
    "South Sudan",
    "Uganda", "Tanzania", 
    # ECCAS (11 countries corrected, adding Rwanda)
    "Angola", "Burundi", "Cameroon", "Central African Republic", "Chad", "Congo",
    "Democratic Republic of the Congo", "Equatorial Guinea", "Gabon", "São Tomé and Príncipe", "Rwanda",
    # ECOWAS
    "Benin", "Burkina Faso", "Cape Verde", "Côte d’Ivoire", "Gambia", "Ghana", "Guinea",
    "Guinea-Bissau", "Liberia", "Mali", "Niger", "Nigeria", "Senegal", "Sierra Leone",
    "Togo",
    # IGAD
    "Djibouti", "Eritrea", "Ethiopia", "Kenya", "Somalia", "South Sudan", "Sudan", "Uganda",
    # SADC (16 countries corrected)
    "Angola", "Botswana", "Democratic Republic of the Congo", "Comoros",
    "Lesotho", "Madagascar", "Malawi", "Mauritius",
    "Mozambique", "Namibia", "Seychelles", "South Africa",
    "Tanzania", "Zambia", "Zimbabwe", "Eswatini"
  )
)

# Extract shortnames from the Community column
dt_rec$Region_Code <- paste0("AUREC_", sub(".*\\((.*)\\).*", "\\1", dt_rec$Region))
dt_rec$ISO3Code <- countrycode::countrycode(dt_rec$Country, origin = "country.name", destination = "iso3c")
dt_rec$Regional_Grouping <- "AUREC" 
dt_rec <- dt_rec[,.(Regional_Grouping, Region, Region_Code, Country, ISO3Code)]
head(dt_rec)
table(dt_rec$Region)
dt_rec[, Region_Code := gsub("-", "_", Region_Code)]
table(dt_rec$Region_Code)
dt_rec[, uniqueN(ISO3Code), by = Region_Code]


dcname <- fread("raw_data/country_name/geographic_areas.csv")
dcname <- dcname[nchar(id) == 3,.(id, name)]
setnames(dcname, "name", "Country")
dt_rec[, Country:= NULL]
dt_rec <- merge(dt_rec, dcname, by.x = "ISO3Code", by.y = "id", all.x = TRUE)
dt_rec <- dt_rec[,.(Regional_Grouping, Region, Region_Code, Country, ISO3Code)]
setorder(dt_rec, Region, Country)

# Save the data to output folder 
fwrite(dt_rec, "output/African Union/AU_regional economic communities.csv")

# 
# when need wide format
dt_rec_w <- data.table::dcast(dt_rec, ISO3Code ~ Region_Code, value.var = "Region")
