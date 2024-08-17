
source("script/util.R")
country_codelist_url <- "https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/codelist/UNICEF/CL_COUNTRY/latest/?format=sdmx-json&detail=full&references=none"

response <- GET(country_codelist_url)
# Check if the request was successful
if (response$status_code == 200) {
  # Parse the JSON content
  content <- content(response, "text")
  json_data <- fromJSON(content, flatten = TRUE)
}
dt_country <- as.data.frame(json_data$data$codelists$codes)

setDT(dt_country)


dt_country <- fread("raw_data/country_name/geographic_areas.csv")

unique(dt_country$parent)
reg_parent <- unique(dt_country$parent)
reg_parent <- reg_parent[!reg_parent %in% c("")]
sapply(reg_parent, function(x) dir.create(file.path("intermediate", x)))
sapply(reg_parent, function(x) dir.create(file.path("output", x)))

create.script <- function(parent0){
  script_name <- paste0("script/individual_region/", tolower(parent0), ".R")
  script_content <- paste0("# script to prepare intermediate data from raw for region ", parent0)
  writeLines(script_content, con = script_name)
}
sapply(reg_parent, create.script)