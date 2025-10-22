import requests
import pandas as pd
import os
import argparse


# python unsdg_api_m49_mapping_download.py C:\gitRepos\Country-and-Region-Metadata\output\UNSDG\m49_mapping.csv

# API endpoint
url_m49 = "https://unstats.un.org/UNSDWebsiteAPI/Home/get-m49"
headers = {"accept": "application/json"}


def download_m49_mapping(output_file):
    """
    Downloads the M49 mapping data from the UN Statistics Division API and saves it as a CSV file.

    Args:
        output_folder (str): The path to the folder where the output CSV file will be saved.
    """
    # Make the GET request to the API
    response = requests.get(url_m49, headers=headers)
    response.raise_for_status()  # Raise an exception for bad status codes

    # Load the JSON data
    data = response.json()

    # Extract the relevant data
    df = pd.DataFrame(data)

    # Define the columns to be extracted
    columns_to_keep = [
        "m49",
        "isoAlpha2",
        "isoAlpha3",
        "nameEN",
        "nameFR",
        "nameES",
        "nameRU",
        "nameZH",
        "nameAR",
        "isLDC",
        "isLLDC",
        "isSIDS",
        "parentM49",
        "isLeaf",
    ]

    # keep a subset of the cols
    df = df[columns_to_keep]

    # Save the DataFrame to a CSV file
    df.to_csv(output_file, index=False)
    print(f"Successfully downloaded and saved M49 mapping to {output_file}")


if __name__ == "__main__":
    # Set up argument parser
    parser = argparse.ArgumentParser(
        description="Download M49 mapping data from the UN Statistics Division API."
    )
    parser.add_argument("output_file", help="The CSV output file.")

    # Parse the arguments
    args = parser.parse_args()

    # Call the download function
    download_m49_mapping(args.output_file)
