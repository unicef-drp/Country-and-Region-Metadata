# Country-and-Region-Metadata

## Purpose of repository

* Produce intermediate files that can be used as input to metadata utilized by all sectors
* Avoid duplication work of cleaning raw data

## Setup

We aim to align all the coding with data warehouse.   
**raw_data**: Contains the original input files for producing the "output", folder names should follow the `regional_grouping`, e.g., "UNICEF_PROG_REG_GLOBAL"  
**output**: Contains files for each regional grouping (or `parent`), named by the `regional_grouping`, e.g., "UNICEF_PROG_REG_GLOBAL.csv"  
**scripts**: Contains the scripts to produce the output files, e.g., "UNICEF_PROG_REG_GLOBAL.R"  
**R**: Contains general functions used by each script, e.g. "general_functions.R"  

## Output files

The output files from this project serve as inputs for downstream processes.
The data is in long format, where each region is mapped to all the `ISO3Code` values belonging to it.

![image](https://github.com/user-attachments/assets/68087586-b0e1-4ca6-9d41-bd1c13066f32)

In this way, the data can be easily reshaped into a wide format if needed using `ISO3Code ~ Region_Code`. Then every row represents an ISO3Code/Country, and every region becomes a column
```
# for example
dt_unicef_prog <- fread("output/UNICEF_PROG_REG_GLOBAL.csv")
dt_unicef_prog_wide <- data.table::dcast(dt_unicef_prog, ISO3Code ~ Region_Code, value.var = "Region")
head(dt_unicef_prog_wide)
```
![image](https://github.com/user-attachments/assets/d7f51c28-4cdd-440a-b2e8-c5319f956cb0)

