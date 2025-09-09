# Python Scripts for Downloading Regional Data
This repository provides Python scripts to download regional aggregates from APIs or other data sources.  
We are transitioning to API-based access for faster, more reliable updates. **Automation is preferred over static files.**

## Installation
### Prerequisites
- Python 3.8+ (check with `python --version`)

### Steps (Windows)
1. Create a Virtual Environemnt with the command: python -m venv .venv
2. Activate the Virtual Environemnt with the command: .venv\Scripts\activate
3. Install the dependencies with the command: pip install -r requirements.txt


## Usage
Each script in the Python folder downloads a specific regional aggregate.  
As the project grows, common functionality may be moved into reusable "library" modules.

Steps to run the scripts:
- Install Python
- create a virtual environment with the command: python -m venv .venv
- activate the virtual environment with the command: .venv\Scripts\activate
- install the requirements: pip install -r requirements.txt
- Run the script

### unsdg_api_download.py
This script downloads the the **UNSDG Regional aggregates** from the https://unstats.un.org server.  
It generates multiple .csv output files, one for each UN-defined hierarchy, such as:

* UNSDG_Land_Locked_Developing_Countries_(LLDC).csv
* UNSDG_Least_Developed_Countries_(LDC).csv


to run the script use the command: python unsdg_api_download.py <output_folder> (e.g. python unsdg_api_download.py c:\unstats_regions)
