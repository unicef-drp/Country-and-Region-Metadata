# Country-and-Region-Metadata

## Overview of Repository

* **Purpose:** Create a useful metadata solution for all sectors — flexible, used by everyone, and easy to collaborate.
* Produce modularized output (based on regional grouping) that all sectors can utilize
* There is one csv output, one script, and one raw input folder for each regional grouping --- all named by the regional grouping
* All outputs follow the same format and use the same code as the data warehouse
* Avoid duplication work of cleaning raw data

## Setup

We aim to align all the coding with the data warehouse.   
* **raw_data**: Contains the original input files for producing the "output", folder names should follow the `regional_grouping`, e.g., "UNICEF_PROG_REG_GLOBAL"  
* **output**: Contains files for each regional grouping (or `parent`), named by the `regional_grouping`, e.g., "UNICEF_PROG_REG_GLOBAL.csv"  
* **scripts**: Contains the scripts to produce the output files, e.g., "UNICEF_PROG_REG_GLOBAL.R"  
* **R**: Contains general functions used by each script, e.g. "general_functions.R"  

## Output

The output files from this project serve as inputs for downstream processes.
The data is in a long format, where each region is mapped to all the `ISO3Code` values belonging to it.  
**Format:**   
`Regional_Grouping`: uppercase, only connected by underscore, no hypen or space, e.g., "UNICEF_PROG_REG_GLOBAL"  
`Region_Code`: same code as used by the data warehouse, uppercase, only connected by underscore, no hypen or space, and lead by `Regional_Grouping`. e.g.,"SDGRC_ESCWA_NOCONFLICT_MID""


![image](https://github.com/user-attachments/assets/68087586-b0e1-4ca6-9d41-bd1c13066f32)

In this way, the data can be easily reshaped into a wide format if needed using `ISO3Code ~ Region_Code`. Then every row represents an ISO3Code/Country, and every region becomes a column
```
# for example
dt_unicef_prog <- fread("output/UNICEF_PROG_REG_GLOBAL.csv")
dt_unicef_prog_wide <- data.table::dcast(dt_unicef_prog, ISO3Code ~ Region_Code, value.var = "Region")
head(dt_unicef_prog_wide)
```
![image](https://github.com/user-attachments/assets/d7f51c28-4cdd-440a-b2e8-c5319f956cb0)

## Update    
### 2025   
add African Union, UNICEF programme region, SDGRC (Regional Commissions)   
add WB income regions and WB regions       
add UNICEF reporting (incl Kosovo, 203 countries in total)   
add SDG M49 regions  



