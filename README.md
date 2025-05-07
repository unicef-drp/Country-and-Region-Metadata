# Country-and-Region-Metadata

## Overview

-   **Purpose: To create a useful metadata solution for all sectors—both for upstream input and as a reference for verification**
- It is flexible, easy to collaborate on, and helps avoid duplicate work
- Produces modularised output (based on regional grouping) that all sectors can use; a combined output file is also saved
- Each regional grouping has one CSV output, one script, and one raw input folder—all named according to the regional grouping
- All outputs follow the same format and use the same codebase as the data warehouse

## Setup

We aim to align all the coding with the data warehouse.
-  **raw_data**: Contains the original input files for producing the "output", folder names should follow the `regional_grouping`, e.g., "UNICEF_PROG_REG_GLOBAL"
-  **output**: Contains files for each regional grouping (or `parent`), named by the `regional_grouping`, e.g., "UNICEF_PROG_REG_GLOBAL.csv"
-  **script for output**: Contains the scripts to produce the output files, e.g., "UNICEF_PROG_REG_GLOBAL.R"
-  **R**: Contains general functions used by each script, e.g. "general_functions.R"

## Output

The output files from this project serve as inputs for downstream processes. The data is in a long format, where each region is mapped to all the `ISO3Code` values belonging to it.\
**Format:**\
`Regional_Grouping`: uppercase, only connected by underscore, no hyphen or space, e.g., "UNICEF_PROG_REG_GLOBAL"\
`Region_Code`: same code as used by the data warehouse, uppercase, only connected by underscore, no hyphen or space, and led by `Regional_Grouping`. e.g., "AUREC_UMA"![image](https://github.com/user-attachments/assets/68087586-b0e1-4ca6-9d41-bd1c13066f32)

### All the _csv_ outputs into one
The combined file for all regions is also saved in the "output" folder:  
https://raw.githubusercontent.com/unicef-drp/Country-and-Region-Metadata/refs/heads/main/output/all_regions_long_format.csv

It can also be created easily using an existing function: 
```         
library(data.table)
source("R/general_functions.R")
dt_all <- bind.all.output()
```

### Easily reshaped into a wide format
Reshape the long-format output using `ISO3Code ~ Region_Code`. Then every row represents an ISO3Code/Country, and every region becomes a column.

```         

dt_unicef_prog <- fread("output/UNICEF_PROG_REG_GLOBAL.csv")
dt_unicef_prog_wide <- data.table::dcast(dt_unicef_prog, ISO3Code ~ Region_Code, value.var = "Region")
head(dt_unicef_prog_wide)
```

![image](https://github.com/user-attachments/assets/d7f51c28-4cdd-440a-b2e8-c5319f956cb0)

## Update

### 2025

add African Union, UNICEF programme region, SDGRC (Regional Commissions)\
add WB income regions and WB regions\
add UNICEF reporting (incl Kosovo, 203 countries in total)("output/UNICEF_REP_REG_GLOBAL.csv")\
add SDG M49 regions ("output/UNSDG_REGION_GLOBAL.csv")
