# Python Scripts for Downloading Regional Data
This repository provides Python scripts to download regional aggregates from UNSDG APIs.  
We are transitioning to API-based access for faster, more reliable updates. **Automation is preferred over static files.**

## Installation
### Prerequisites
- Python 3.8+ (check with `python --version`)

### Steps (Windows)
1. Create a Virtual Environemnt with the command: `python -m venv .venv`
2. Activate the Virtual Environemnt with the command: `.venv\Scripts\activate`
3. Install the dependencies with the command: `pip install -r requirements.txt`


## Usage

This project contains three main scripts for downloading and processing UNSDG data.

### `00_run_unsdg.py` (Recommended)

This is the main script to execute the entire download and processing pipeline. It runs the other two scripts in the correct order.

**Usage:**
```shell
python 00_run_unsdg.py <output_folder>
```

**Example:**
```shell
python 00_run_unsdg.py ..\output\UNSDG
```

This will create the `..\output\UNSDG` directory (if it doesn't exist) and place all the output files there.

---

### `01_unsdg_api_m49_mapping_download.py`

This script downloads the M49 country and region mapping from the UN Statistics Division API. This file is required by the `02_unsdg_api_download.py` script.

**Usage:**
```shell
python 01_unsdg_api_m49_mapping_download.py <output_file>
```

**Example:**
```shell
python 01_unsdg_api_m49_mapping_download.py ..\output\UNSDG\m49_mapping.csv
```

---

### `02_unsdg_api_download.py`

This script downloads the UNSDG regional hierarchies, processes them, and enriches them with `isoAlpha3` codes from the M49 mapping file.

**Usage:**
```shell
python 02_unsdg_api_download.py <output_folder> <m49_mapping_file>
```

**Example:**
```shell
python 02_unsdg_api_download.py ..\output\UNSDG ..\output\UNSDG\m49_mapping.csv
```

---

## Output Files

Running the main script (`00_run_unsdg.py`) will produce the following files in the specified output folder:

1.  **`m49_mapping.csv`**: Contains the mapping between M49 codes and other country identifiers like ISO alpha-2 and alpha-3 codes.

2.  **`UNSDG_*.csv` files**: A series of files, one for each UNSDG regional hierarchy. The exact number and names of these files may change depending on the data provided by the API. Examples include:
    *   `UNSDG_Geographical_Regions.csv`
    *   `UNSDG_Land_Locked_Developing_Countries_(LLDC).csv`
    *   `UNSDG_Least_Developed_Countries_(LDC).csv`
    *   `UNSDG_Small_Island_Developing_States_(SIDS).csv`
    *   `UNSDG_Sustainable_Development_Goal_(SDG)_Regions.csv`