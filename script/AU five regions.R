library(data.table)


# don't run (YL draft)

dc <- CME.assistant::get.country.info.CME(2024)
dc_au <- melt.data.table(dc, id.vars = c("ISO3Code", "OfficialName"), measure.vars = c("AURegion1", "AURegion2"),
              value.name = "Region")
dc_au <- dc_au[!is.na(Region) & Region!= ""]



# Region_Code, Region, Regional_Grouping
# AU_AFRICA	Africa (African Union)		AU
# AU_CENTRAL_AFRICA	Central Africa (African Union)		AU
# AU_EASTERN_AFRICA	Eastern Africa (African Union)		AU
# AU_NORTHERN_AFRICA	Northern Africa (African Union)		AU
# AU_SOUTHERN_AFRICA	Southern Africa (African Union)		AU
# AU_WESTERN_AFRICA	Western Africa (African Union)		AU

dc_au[, Region:= paste(Region,  "(African Union)")]
dc_au[, Regional_Grouping:= "AU"]
dc_au[, Region_Code := dplyr::recode(Region, 
                                     "Africa (African Union)" = "AU_AFRICA",
                                     "Central Africa (African Union)" = "AU_CENTRAL_AFRICA",
                                     "Eastern Africa (African Union)" = "AU_EASTERN_AFRICA",
                                     "Northern Africa (African Union)" = "AU_NORTHERN_AFRICA",
                                     "Southern Africa (African Union)" = "AU_SOUTHERN_AFRICA",
                                     "Western Africa (African Union)" = "AU_WESTERN_AFRICA")]
setnames(dc_au, "OfficialName", "Country")
dc_au <- dc_au[,.(Regional_Grouping, Region, Region_Code, Country, ISO3Code)]
head(dc_au)
table(dc_au$Region)
fwrite(dc_au, "output/African Union/AU_5regions.csv")



library("data.table")
library("jsonlite")
library("httr")

get_country_labels <- function(country_codelist_url, lang = "en") {
  # Perform the GET request with Accept-Language header
  response <- httr::GET(
    country_codelist_url,
    httr::add_headers(`Accept-Language` = lang)
  )
  
  # Check if the response is successful
  if (httr::status_code(response) == 200) {
    # Decode the content
    content_text <- httr::content(response, "text", encoding = "UTF-8")
    
    # Parse JSON
    json_data <- jsonlite::fromJSON(content_text, flatten = TRUE)
    
    # Extract the required portion of the JSON
    codes <- json_data$data$codelists$codes
    
    # Convert to data.table
    dt <- data.table::as.data.table(codes)
    
    # Drop unnecessary columns
    cols_to_remove <- c("names", "links", "parent")
    dt <- dt[, -..cols_to_remove]
    
    # Return the resulting data.table
    return(dt)
  } else {
    stop(paste("Failed to fetch data. Status code:", httr::status_code(response)))
  }
}


url_sdmx <- "https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/codelist/UNICEF/CL_COUNTRY/latest/?format=sdmx-json&detail=full&references=none"
dt1 <- get_country_labels(country_codelist_url = url_sdmx)
