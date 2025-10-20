import subprocess
import argparse
import os
import sys

def run_script(script_name, *args):
    """Runs a python script using the same interpreter and checks for errors."""
    try:
        print(f"Running {script_name}...")
        command = [sys.executable, script_name] + list(args)
        result = subprocess.run(command, check=True, capture_output=True, text=True, encoding='utf-8')
        print(result.stdout)
        if result.stderr:
            print("Error output:")
            print(result.stderr)
        print(f"Successfully finished {script_name}.")
    except subprocess.CalledProcessError as e:
        print(f"Error running {script_name}:")
        print(e.stdout)
        print(e.stderr)
        sys.exit(1)

def main():
    """
    Main function to run the UNSDG download scripts in sequence.
    """
    parser = argparse.ArgumentParser(
        description="Run UNSDG download scripts in sequence. This script runs 01_unsdg_api_m49_mapping_download.py and 02_unsdg_api_download.py."
    )
    parser.add_argument(
        "output_folder",
        help="The folder where the output files will be saved."
    )
    
    args = parser.parse_args()

    # Define file paths
    m49_output_file = os.path.join(args.output_folder, "m49_mapping.csv")
    
    # Ensure output directory exists
    os.makedirs(args.output_folder, exist_ok=True)

    # Script paths
    script1 = "01_unsdg_api_m49_mapping_download.py"
    script2 = "02_unsdg_api_download.py"

    # Run scripts in sequence
    run_script(script1, m49_output_file)
    run_script(script2, args.output_folder)
    
    print("All scripts executed successfully.")

if __name__ == "__main__":
    main()
