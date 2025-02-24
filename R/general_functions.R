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
  dir_output <- dir_output[!grepl("all_output", dir_output)]
  read.csv <- function(x){
    dt1 <- fread(x)
    if(dt1[ISO3Code == "" | is.na(ISO3Code),.N] > 1)message("check ISO3Code in ", x)
    dt1
  }
  dt_bind <- rbindlist(lapply(dir_output, read.csv), fill = TRUE)
  return(dt_bind)
}

create.code.book <- function(){
  dt_bind <- bind.all.output()
  dt_code <- unique(dt_bind[,.(Regional_Grouping, Region_Code, Region, UNSD_Code)])
  fwrite(dt_code, "output/codebook_of_region_code_and_name.csv")
}

get.sdmx <- function(x){
  dt_meta <- fread("raw_data/SDMX_meta_info/geographic_areas.csv")
  print( dt_meta[, table(parent)])
  return(dt_meta)
}

save.wide.format <- function(){
  dt_all_regions <- bind.all.output()[,.(ISO3Code, Region_Code, Region)]
  dt_wide <- dcast(dt_all_regions, ISO3Code ~ Region_Code, value.var = "Region")
  fwrite(dt_wide, "output/all_output_wide_format.csv")
}



# for checking ------------------------------------------------------------


check.against.dc <- function(dt_out, dc_col0){
  stopifnot(dc_col0 %in% colnames(dc))
  regs <- dc[, unique(get(dc_col0))]
  regs <- regs[!is.na(regs)][regs!=""]
  message("check for ", paste(regs, collapse = ", "))
  
  if(!all(regs %in% unique(dt_out$Region))){
    stop("Regions are not in dt_out: ", paste(regs[!regs %in% unique(dt_out$Region)], collapse = ", "))
  }
  check.reg0 <- function(reg0){
    print(paste("comparing --- ", reg0, " ---------- "))
    
    iso.dc  <- dc[get(dc_col0) == reg0, unique(ISO3Code)]
    iso.out <- dt_out[Region == reg0, unique(ISO3Code)]
    iso.out.new <- iso.out[!iso.out %in% iso.dc]
    iso.dc.new  <- iso.dc[!iso.dc %in% iso.out]
    if(length(iso.out.new) > 0){
      print(paste("fyi: iso3 in output but not in dc (which is fine): ", paste(iso.out.new, collapse = ", ")))
    }
    if(length(iso.dc.new) > 0){
      message("[Check!] iso3 in country.info.CME but not in output: ", paste(iso.dc.new, collapse = ", "))
    }
  }
  invisible(lapply(regs, check.reg0))
}
