# Download areas and regions from UNSDG APIs. Generate UNSDG - UNICEF areas and regional mapping.
## The python script
- Downloads the M49 (used by UNSDG)- ISO3 (used by unicef) codes map from UNSDG apis.
- Downloads the UNSDGs Regional Hierarchy (list of regions and countries withing the region)
- Downloads a mapping file from UNICEF's Github containing a manual mapping from some areas that are not contained in the M49 - ISO3 mapping file provided by UNSD (region codes are not standard, there is no official mapping).

## Output files
1.  **`m49_mapping.csv`**: Contains the mapping between M49 codes and other country identifiers like ISO alpha-2 and alpha-3 codes. The manual mapped regions are appended at the end.

2.  **`UNSDG_*.csv` files**: A series of files, one for each UNSDG regional hierarchy. The exact number and names of these files may change depending on the data provided by the API. Examples include:
    *   `UNSDG_Geographical_Regions.csv`
    *   `UNSDG_Land_Locked_Developing_Countries_(LLDC).csv`
    *   `UNSDG_Least_Developed_Countries_(LDC).csv`
    *   `UNSDG_Small_Island_Developing_States_(SIDS).csv`
    *   `UNSDG_Sustainable_Development_Goal_(SDG)_Regions.csv`


## Installation
### Prerequisites
- Python 3.8+ (check with `python --version`)

### Steps (Windows)
1. Create a Virtual Environemnt with the command: `python -m venv .venv`
2. Activate the Virtual Environemnt with the command: `.venv\Scripts\activate`
3. Install the dependencies with the command: `pip install -r requirements.txt`


## Usage

Run the `00_run_unsdg.py` using the command




```shell
python 00_run_unsdg.py <path to the MAP_UNSD_UNICEF_regions.csv> <output_folder>
```

**Example:**
```shell
 output\UNSDG
python 00_run_unsdg.py C:\Country-and-Region-Metadata\raw_data\UNSDG_REGION_GLOBAL\MAP_UNSD_UNICEF_regions.csv ..\output\UNSDG
```

This will create the `..\output\UNSDG` directory (if it doesn't exist) and place all the output files there.