# To pull all output into one ------------------------------------------------

library(data.table)
source("R/general_functions.R")
combined_data <- bind.all.output()


# To pull selected output into one -------------------------------------------
library("tidyverse")

# Step 1: List your CSV URLs (RAW links)
csv_urls <- c(
  "https://raw.githubusercontent.com/unicef-drp/Country-and-Region-Metadata/refs/heads/main/output/UNICEF_PROG_REG_GLOBAL.csv",
  "https://raw.githubusercontent.com/unicef-drp/Country-and-Region-Metadata/refs/heads/main/output/UNICEF_REP_REG_GLOBAL.csv",
  "https://raw.githubusercontent.com/unicef-drp/Country-and-Region-Metadata/refs/heads/main/output/WB_INCOME.csv",
  "https://raw.githubusercontent.com/unicef-drp/Country-and-Region-Metadata/refs/heads/main/output/WB_REG_GLOBAL.csv"
)

# Step 2: Define a function to read CSV and add source
read_csv_from_url <- function(url) {
  read_csv(url, col_types = cols(.default = "c")) %>%
    mutate(source_file = basename(url))  # basename just keeps the filename
}

# Step 3: Read and append all the CSVs
combined_data <- map_dfr(csv_urls, read_csv_from_url)

# Step 4: Done! Now you have a "source_file" column
glimpse(combined_data)
