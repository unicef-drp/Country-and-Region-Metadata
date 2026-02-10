import subprocess
import argparse
import os
import sys
import pandas as pd
import csv

import unsdg_api_m49_mapping_download
import unsdg_tree_api_download

# regions to exclude
REGIONS_TO_EXCLUDE = ["World_(total)_by_MDG_regions"]

OUTPUT_COL_ORDER = [
    "Regional_Grouping",
    "Region",
    "Region_Code",
    "Area",
    "Area_Code_M49",
    "isoAlpha3",
    "Type",
]

# def run_script(script_name, *args):
#     """Runs a python script using the same interpreter and checks for errors."""
#     try:
#         print(f"Running {script_name}...")
#         command = [sys.executable, script_name] + list(args)
#         result = subprocess.run(command, check=True, capture_output=True, text=True, encoding='utf-8')
#         print(result.stdout)
#         if result.stderr:
#             print("Error output:")
#             print(result.stderr)
#         print(f"Successfully finished {script_name}.")
#     except subprocess.CalledProcessError as e:
#         print(f"Error running {script_name}:")
#         print(e.stdout)
#         print(e.stderr)
#         sys.exit(1)


def _load_unsd_unicef_regions_map(map_file_path) -> pd.DataFrame:
    df = pd.read_csv(map_file_path, encoding="utf-8", dtype=str)
    return df


def _process_hierarchy(
    df_map_m49_unicef: pd.DataFrame, df_unsdg_hierarchy: pd.DataFrame
) -> pd.DataFrame:

    # Start hierarchy processing and mapping

    # Add UNICEF codes
    # remove leading 0s from the m49 code to match the items in the Tree (pulled later)
    df_map_m49_unicef["m49"] = df_map_m49_unicef["m49"].str.lstrip("0")
    # Merge with m49 mapping data
    df_unsdg_hierarchy = pd.merge(
        df_unsdg_hierarchy,
        df_map_m49_unicef,
        left_on="Area_Code_M49",
        right_on="m49",
        how="left",
    )
    df_unsdg_hierarchy = df_unsdg_hierarchy.drop(columns=["m49"])

    df_unsdg_hierarchy = df_unsdg_hierarchy[OUTPUT_COL_ORDER]

    return df_unsdg_hierarchy


def _merge_m49_maps(
    df_map_m49_unicef: pd.DataFrame, df_unsd_unicef_regions_map: pd.DataFrame
) -> pd.DataFrame:
    df = df_map_m49_unicef.copy()
    df["m49_s"] = df["m49"].str.lstrip("0")

    df = pd.merge(
        df,
        df_unsd_unicef_regions_map,
        left_on="m49_s",
        right_on="M49_code",
        how="left",
    )

    df = df.drop(columns=["m49_s", "M49_code", "M49_label", "UNICEF_label", "Notes"])
    df.loc[~df["isoAlpha3"].isna(), "UNICEF_code"] = df["isoAlpha3"]

    return df


def main():
    """
    Main function to run the UNSDG download scripts in sequence.
    """
    parser = argparse.ArgumentParser(
        description="Run UNSDG download scripts in sequence. This script runs 01_unsdg_api_m49_mapping_download.py and 02_unsdg_api_download.py."
    )
    parser.add_argument(
        "map_regions_path",
        help="The csv file containing the map from UNSD region codes to UNICEF region codes",
    )

    parser.add_argument(
        "output_folder", help="The folder where the output files will be saved."
    )

    args = parser.parse_args()

    # Load the M49-ISO3 codes map
    df_map_m49_unicef = unsdg_api_m49_mapping_download.download_m49_mapping()

    # Load the unsdg hierarchies (region->country)
    df_unsdg_hierarchy = unsdg_tree_api_download.get_hierarchies()
    # Load the manual map for the regions
    df_unsd_unicef_regions_map = _load_unsd_unicef_regions_map(args.map_regions_path)

    # print(df_map_m49_unicef.head())
    # print(df_unsd_unicef_regions_map.head())

    # Ensure output directory exists
    os.makedirs(args.output_folder, exist_ok=True)

    df_map_m49_unicef = _merge_m49_maps(df_map_m49_unicef, df_unsd_unicef_regions_map)

    # Some areas are missing from the UNSD Tree hierarchy, add them
    items_to_add = [
        "UNSDG_WESTERNASIANORTHERNAFR",
        "UNSDG_CENTRALASIASOUTHERNASIA",
        "UNSDG_EASTERNASIASOUTHEASTERNASIA",
        "UNSDG_EUROPENORTHERNAMR",
        "UNSDG_OCEANIAexAUSNZL",
    ]
    items_to_add = [
        {
            "UNICEF_code": i,
            "m49": df_unsd_unicef_regions_map.loc[
                df_unsd_unicef_regions_map["UNICEF_code"] == i, "M49_code"
            ].item(),
        }
        for i in items_to_add
    ]
    df_map_m49_unicef = pd.concat([df_map_m49_unicef, pd.DataFrame(items_to_add)])

    # Save the m49 mapping file
    m49_output_file = os.path.join(args.output_folder, "m49_mapping.csv")
    df_map_m49_unicef.to_csv(
        m49_output_file, index=False, encoding="utf-8", quoting=csv.QUOTE_MINIMAL
    )

    # Process and map the hierarchies
    df_unsdg_hierarchy = _process_hierarchy(df_map_m49_unicef, df_unsdg_hierarchy)

    for region_name in list(df_unsdg_hierarchy["Regional_Grouping"].unique()):
        if region_name in REGIONS_TO_EXCLUDE:
            continue
        file_name = f"UNSDG_{region_name}.csv"
        file_path = os.path.join(args.output_folder, file_name)
        df_region = df_unsdg_hierarchy[
            df_unsdg_hierarchy["Regional_Grouping"] == region_name
        ]
        df_region.to_csv(
            file_path, index=False, encoding="utf-8", quoting=csv.QUOTE_MINIMAL
        )

    print("All scripts executed successfully.")


if __name__ == "__main__":

    main()
