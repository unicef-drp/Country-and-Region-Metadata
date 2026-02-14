# UNSDG–UNICEF Area and Region Mapping
This project downloads country and regional metadata from the UNSDG APIs and generates harmonized mappings between UNSDG M49 codes and UNICEF ISO3 country codes. It also incorporates a manual mapping for regions that are not officially covered by the UNSD M49 standard.  

The output is a set of CSV files that can be reused across data pipelines requiring consistent country and region identifiers.

---

## What the script does
- Downloads the M49 - ISO (alpha-2 and alpha-3) country code mapping from UNSDG APIs
- Downloads UNSDG regional hierarchies (regions and their member countries)
- Appends a manually curated mapping from UNICEF's Github for non-standard regions where no official mapping exists

---
## Output files

1. **`m49_mapping.csv`**  
   Mapping between M49 codes and other country identifiers (ISO alpha-2 and alpha-3).  
   Manually mapped regions are appended at the end of the file.

2. **`UNSDG_*.csv` files**  
   One CSV per UNSDG regional hierarchy. The exact set of files depends on the API response.

   Example outputs:
    *   `UNSDG_Geographical_Regions.csv`
    *   `UNSDG_Land_Locked_Developing_Countries_(LLDC).csv`
    *   `UNSDG_Least_Developed_Countries_(LDC).csv`
    *   `UNSDG_Small_Island_Developing_States_(SIDS).csv`
    *   `UNSDG_Sustainable_Development_Goal_(SDG)_Regions.csv`

---

## Installation

### Prerequisites
- Python 3.8 or newer

### Setup

#### Windows
```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

### Usage
Run the main script (If the output directory does not exist, it will be created automatically.)
```bash
python 00_run_unsdg.py <path_to_MAP_UNSD_UNICEF_regions.csv> <output_folder>
```

#### Example
```bash
python 00_run_unsdg.py C:\Country-and-Region-Metadata\raw_data\UNSDG_REGION_GLOBAL\MAP_UNSD_UNICEF_regions.csv C:\Country-and-Region-Metadata\output\UNSDG
```

