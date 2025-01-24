# general functions

# add country names. Format and sort output
add.country.name <- function(dc, dcname){
  dcname <- readRDS("raw_data/SDMX_meta_info/country_name.rds")
  stopifnot("ISO3Code" %in% colnames(dc))
  dc <- dplyr::left_join(dc, dcname, by = c("ISO3Code" = "id"))
  dc <- dc[,.(Regional_Grouping, Region, Region_Code, Country, ISO3Code)]
  setorder(dc, Region, Country)
  return(dc)
}

# create codebook of region_code and region names
bind.all.output <- function(){
  dir_output <- list.files("output", full.names = TRUE)
  dir_output <- dir_output[grepl(".csv", dir_output)]
  dir_output <- dir_output[!grepl("codebook", dir_output)]
  dt_bind <- rbindlist(lapply(dir_output, fread))
  return(dt_bind)
}

create.code.book <- function(){
  dt_bind <- bind.all.output()
  dt_code <- unique(dt_bind[,.(Regional_Grouping, Region_Code, Region)])
  fwrite(dt_code, "output/codebook_of_region_code_and_name.csv")
}
