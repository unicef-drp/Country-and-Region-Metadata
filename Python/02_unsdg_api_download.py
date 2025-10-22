import requests
import csv
import argparse
import os
import sys

import pandas as pd

# API endpoint
url_geo_tree = "https://unstats.un.org/sdgs/UNSDGAPIV5/v1/sdg/GeoArea/Tree"
headers = {"accept": "application/json"}

# roots to exclude
roots_to_exclude = ["World_(total)_by_MDG_regions"]

# Columns rename
col_rename_map = {
    "geoAreaCode": "Region_Code",
    "geoAreaName": "Region",
    "child_geoAreaName": "Area",
    "child_geoAreaCode": "Area_Code_M49",
    "child_type": "Type",
}


def download_json(url: str, headers: dict) -> list:

    response = requests.get(url, headers=headers)

    # Check for successful response
    if response.status_code == 200:
        data = response.json()  # Parse JSON content
        return data
    else:
        print(f"Request failed with status code {response.status_code}")
    return []


def flatten_hierarchy(node, parent=None, results=None):

    if results is None:
        results = []
    # Extract current node info
    current = {
        "geoAreaCode": node.get("geoAreaCode"),
        "geoAreaName": node.get("geoAreaName"),
        "type": node.get("type"),
    }

    # If there is a parent, record the relationship
    if parent:
        results.append(
            {
                "parent_geoAreaCode": parent["geoAreaCode"],
                "parent_geoAreaName": parent["geoAreaName"],
                "parent_type": parent["type"],
                "geoAreaCode": current["geoAreaCode"],
                "geoAreaName": current["geoAreaName"],
                "type": current["type"],
            }
        )
    else:
        # For the root, we still include it but parent fields are empty
        results.append(
            {
                "parent_geoAreaCode": "",
                "parent_geoAreaName": "",
                "parent_type": "",
                "geoAreaCode": current["geoAreaCode"],
                "geoAreaName": current["geoAreaName"],
                "type": current["type"],
            }
        )

        # Recurse for children if present
    children = node.get("children")
    if children:
        for child in children:
            flatten_hierarchy(child, current, results)

    return results


def _get_root_name(root_node):
    ret = root_node.get("geoAreaName", "")
    ret = ret.replace(" ", "_")
    return ret


def reshape_to_unicef_format(cl: list) -> list:
    ret = []
    # Step 1: Keep the regions
    regions = [item for item in cl if item["type"] == "Region"]
    # Step 2: For each region, find its children
    for region in regions:
        region_code = region["geoAreaCode"]
        children = [item for item in cl if item["parent_geoAreaCode"] == region_code]

        for child in children:
            region_copy = region.copy()
            # Attach child info
            region_copy["child_geoAreaCode"] = child["geoAreaCode"]
            region_copy["child_geoAreaName"] = child["geoAreaName"]
            region_copy["child_type"] = child["type"]
            ret.append(region_copy)

    return ret


def main(output_folder, m49_mapping_file):
    try:
        os.makedirs(output_folder, exist_ok=True)
        print(f"Output folder is set to: {output_folder}")
    except Exception as e:
        print(f"Error creating output folder: {e}", file=sys.stderr)
        sys.exit(1)

    # Load M49 mapping file
    try:
        m49_df = pd.read_csv(
            m49_mapping_file,
            usecols=["m49", "isoAlpha3"],
            dtype={"m49": str, "isoAlpha3": str},
        )
    except FileNotFoundError:
        print(
            f"Error: The mapping file was not found at {m49_mapping_file}",
            file=sys.stderr,
        )
        sys.exit(1)
    except Exception as e:
        print(f"Error reading mapping file: {e}", file=sys.stderr)
        sys.exit(1)

    #remove leading spaces from the m49 code to match the items in the Tree (pulled later)
    m49_df["m49"] = m49_df["m49"].str.lstrip("0")

    tree = download_json(url_geo_tree, headers)

    for tree_root_node in tree:
        root_name = _get_root_name(tree_root_node)
        # skip if we don't need this root
        if root_name in roots_to_exclude:
            continue
        flattened = flatten_hierarchy(tree_root_node)

        unicef_flattened = reshape_to_unicef_format(flattened)

        df = pd.DataFrame(data=unicef_flattened, dtype=str)

        df = df.sort_values(by=["parent_geoAreaCode"])
        df = df.drop(
            columns=["type", "parent_type", "parent_geoAreaCode", "parent_geoAreaName"]
        )

        df["Regional_Grouping"] = root_name
        df = df.rename(columns=col_rename_map)

        # Merge with m49 mapping data
        df = pd.merge(df, m49_df, left_on="Area_Code_M49", right_on="m49", how="left")
        df = df.drop(columns=["m49"])

        new_col_order = [
            "Regional_Grouping",
            "Region",
            "Region_Code",
            "Area",
            "Area_Code_M49",
            "isoAlpha3",
            "Type",
        ]

        for c in df.columns:
            assert c in new_col_order, (
                "Rearranging the column order will drop the column " + c
            )

        df = df[new_col_order]

        file_name = f"UNSDG_{root_name}.csv"
        file_path = os.path.join(output_folder, file_name)
        df.to_csv(file_path, index=False, encoding="utf-8", quoting=csv.QUOTE_MINIMAL)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="UNSDG hierarchies to flat CSV.")
    parser.add_argument("output_folder", type=str, help="Path to the output folder")
    parser.add_argument(
        "m49_mapping_file", type=str, help="Path to the M49 mapping CSV file."
    )
    args = parser.parse_args()

    main(args.output_folder, args.m49_mapping_file)
