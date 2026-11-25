# Regional Economic Communities (RECs) for African Union aggregation
# data source: https://au.int/en/organs/recs
# replaced by: 
# data source: UNSD "9. CompositionOfRegions_RCs_20241202.xlsx"
# 

# the "parent" code aligns with data warehouse sdmx meta info
parent_code <- "AUREC"

library("data.table")
source("R/general_functions.R")


# Region_Code                                                 Region
# <char>                                                 <char>
#   1:     AUREC_AMU                               Arab Maghreb Union (AMU)
# 2:  AUREC_COMESA Common Market for Eastern and Southern Africa (COMESA)
# 3: AUREC_CEN_SAD            Community of Sahel-Saharan States (CEN-SAD)
# 4:     AUREC_EAC                           East African Community (EAC)
# 5:   AUREC_ECCAS   Economic Community of Central African States (ECCAS)
# 6:  AUREC_ECOWAS     Economic Community of West African States (ECOWAS)
# 7:    AUREC_IGAD      Intergovernmental Authority on Development (IGAD)
# 8:    AUREC_SADC          Southern African Development Community (SADC)

# change direction of working --- pull from SDGRC directly

dt_rc <- fread("output/SDGRC.csv")
region_code_wanted <-  c("SDGRC_ECA_AMU", "SDGRC_ECA_CEN_SAD",  "SDGRC_ECA_COMESA", "SDGRC_ECA_EAC", 
                         "SDGRC_ECA_ECCAS", "SDGRC_ECA_ECOWAS",  "SDGRC_ECA_IGAD" ,"SDGRC_ECA_SADC",
                         "SDGRC_ECA_ALL",
                         "SDGRC_ECA_CA",
                         "SDGRC_ECA_EA",
                         "SDGRC_ECA_NA",
                         "SDGRC_ECA_SA",
                         "SDGRC_ECA_WA"
                         
                         )
all(region_code_wanted %in% dt_rc$Region_Code) # TRUE

dt_aurec <- dt_rc[Region_Code %in% region_code_wanted, ]

aurec_region_lookup <- data.table(
    Region_Code = c(
        "AUREC_AMU",
        "AUREC_COMESA",
        "AUREC_CEN_SAD",
        "AUREC_EAC",
        "AUREC_ECCAS",
        "AUREC_ECOWAS",
        "AUREC_IGAD",
        "AUREC_SADC"
    ),
    Region = c(
        "Arab Maghreb Union (AMU)",
        "Common Market for Eastern and Southern Africa (COMESA)",
        "Community of Sahel-Saharan States (CEN-SAD)",
        "East African Community (EAC)",
        "Economic Community of Central African States (ECCAS)",
        "Economic Community of West African States (ECOWAS)",
        "Intergovernmental Authority on Development (IGAD)",
        "Southern African Development Community (SADC)"
    )
)

aurec_region_lookup[, Region_Code_Match := sub("^AUREC", "SDGRC_ECA", Region_Code)]
dt_aurec[aurec_region_lookup, on = .(Region_Code = Region_Code_Match), Region := i.Region]
dt_aurec[, Regional_Grouping := parent_code]

# Save the data to output folder 
fwrite(dt_aurec, "output/AUREC.csv")

create.code.book()
