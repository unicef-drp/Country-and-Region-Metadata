# Country-and-Region-Metadata

## Overview

- **Purpose:** Create a practical metadata solution for all sectors, both for upstream inputs and for reference/verification.
- The workflow is flexible, easy to collaborate on, and helps avoid duplicate work.
- It produces modularized outputs in the same format by regional grouping that all sectors can use; a combined output file is also saved.
- Each regional grouping has one CSV output, one script, and one raw input folder, all named after the regional grouping.
- All outputs follow the same format and use the same codebase as the data warehouse.

## Setup

- **raw_data**: Original input files used to produce outputs. Folder names should follow the `regional_grouping` code (for example, `UNICEF_PROG_REG_GLOBAL`).
- **output**: One output CSV per regional grouping (or `parent`). The filename is derived directly from the `regional_grouping` code: `{regional_grouping}.csv`.
- **script for output**: Scripts that generate each output file, typically named `{regional_grouping}.R` (for example, `UNICEF_PROG_REG_GLOBAL.R`).
- **R**: Shared general functions used by output scripts (for example, `general_functions.R`).

## Output

The output files from this project are used as inputs for downstream processes. The data is in long format, where each region is mapped to all `ISO3Code` values that belong to it.

**Format:** This repository aligns with the data warehouse coding scheme:
- `Regional_Grouping`: Uppercase with underscores only (no hyphens or spaces), for example `UNICEF_PROG_REG_GLOBAL`.
- `Region_Code`: Same format as the data warehouse (uppercase with underscores only), prefixed by `Regional_Grouping`, for example `AUREC_UMA`.

### Default output columns

The standard output uses **7 default columns**. Adding more columns is discouraged unless there is a strong downstream requirement.

```r
dtr_SDG[,.(Regional_Grouping, Region, Region_Code, M49Region_Code, Country, ISO3Code, M49_Code)]

head(dtr_SDG)
	Regional_Grouping Region  Region_Code M49Region_Code Country ISO3Code M49_Code
			 <char> <char>       <char>          <int>  <char>   <char>    <int>
1: UNSDG_REGION_GLOBAL Africa UNSDG_AFRICA              2 Algeria      DZA       12
2: UNSDG_REGION_GLOBAL Africa UNSDG_AFRICA              2  Angola      AGO       24
3: UNSDG_REGION_GLOBAL Africa UNSDG_AFRICA              2   Benin      BEN      204
```


### Combine all CSV outputs into one file

The combined file for all regions is also saved in the `output` folder:
<https://raw.githubusercontent.com/unicef-drp/Country-and-Region-Metadata/refs/heads/main/output/all_regions_long_format.csv>

It can be updated using the following function. Whenever a new region is added, update `dt_all` accordingly:

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

## Update

### 2026

- Add UNICEF SP regions.
- Added FAO regions.

### 2025

- Updated WB regions to FY26 and SDGRC to 20251217.
- Added African Union, UNICEF programme region, SDGRC (Regional Commissions)
- Added WB income regions and WB regions.
- Added UNICEF reporting (including Kosovo; 203 countries in total): `output/UNICEF_REP_REG_GLOBAL.csv`.
- Added SDG M49 regions: `output/UNSDG_REGION_GLOBAL.csv`.
