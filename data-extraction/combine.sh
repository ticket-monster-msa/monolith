#!/bin/bash

# Get the base directory from command line argument
base_dir=$1

# Check if the base directory is provided
if [ -z "$base_dir" ]; then
    echo "Usage: $0 <base_directory>"
    exit 1
fi

rm -f cstate_output.csv
rm -f output.csv


# Find all CSV files recursively in the base directory
find "$base_dir" -type f -name "*.csv" -print0 | while IFS= read -r -d '' csv_file; do
    # Extract the directory name from the CSV file path
    dir=$(dirname "$csv_file")
    
    # Determine the architecture based on the directory name
    architecture=$(basename "$dir")

    # Check if the directory name is "micro" or "mono"
    if [ "$architecture" == "micro" ] || [ "$architecture" == "mono" ]; then
        echo "Processing CSV file: $csv_file in directory: $dir"

        # Execute the Python script for each CSV file, passing the architecture as an argument
        python3 extract_file.py "$csv_file" "$architecture"
    fi
done
