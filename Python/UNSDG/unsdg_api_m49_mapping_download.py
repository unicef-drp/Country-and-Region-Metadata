import requests
import pandas as pd
import os
import argparse


# API endpoint
url_m49 = "https://unstats.un.org/UNSDWebsiteAPI/Home/get-m49"
headers = {"accept": "application/json"}


def download_m49_mapping() -> pd.DataFrame:
    """
      Downloads the M49 mapping data from the UN Statistics Division API.
      Example return format:

      [
      {
      "m49": "004",
      "isoAlpha2": "AF",
      "isoAlpha3": "AFG",
      "nameEN": "Afghanistan",
      "nameFR": "Afghanistan",
      "nameES": "Afganistán",
      "nameRU": "Афганистан",
      "nameZH": "阿富汗",
      "nameAR": "أفغانستان",
      "isLDC": true,
      "isLLDC": true,
      "isSIDS": false,
      "parentM49": "034",
      "isLeaf": true,
      "members": null
    }
    ]
    """

    # Make the GET request to the API
    response = requests.get(url_m49, headers=headers)
    response.raise_for_status()  # Raise an exception for bad status codes

    # Load the JSON data
    data = response.json()

    # Extract the relevant data
    df = pd.DataFrame(data)

    # Define the columns to be extracted
    # Select only the columns necessary for the metadata mapping
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

    return df


if __name__ == "__main__":
    # Set up argument parser
    parser = argparse.ArgumentParser(
        description="Download M49 mapping data from the UN Statistics Division API."
    )
    parser.add_argument("output_file", help="The CSV output file.")

    # Parse the arguments
    args = parser.parse_args()

    # Call the download function
    df = download_m49_mapping()

    # Save the DataFrame to a CSV file
    df.to_csv(args.output_file, index=False)
    print(f"Successfully downloaded and saved M49 mapping to {args.output_file}")
