#!/bin/bash

# Output file
output_file="extracted_values.csv"

# Create the header in the output file
echo "#,DateTime,Architecture,File,Total Elapsed Time (sec),Cumulative Package Energy_0 (mWh),Cumulative IA Energy_0 (mWh),Cumulative DRAM Energy_0 (mWh)" > "$output_file"

# Function to extract float values from a file
extract_values() {
    local folder="$1"
    local subfolder="$2"
    local file="$3"
    local filename=$(basename "$file") # Get the filename without path
    
    # Initialize variables for values
    local elapsed_time=""
    local package_energy=""
    local ia_energy=""
    local dram_energy=""
    
    # echo "Extracting values from: $folder/$subfolder/$filename" # Debugging line

    # Ensure consistent line endings with dos2unix
    dos2unix -q "$file"
    
    # Loop through lines in the file
    while IFS= read -r line; do
        # Check for lines containing specific values
        if [[ $line =~ "Total Elapsed Time (sec) = " ]]; then
            elapsed_time=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative Package Energy_0 (mWh) = " ]]; then
            package_energy=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative IA Energy_0 (mWh) = " ]]; then
            ia_energy=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative DRAM Energy_0 (mWh) = " ]]; then
            dram_energy=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        fi
    done < "$file"
    
    # Debugging lines to print extracted values
    echo "Elapsed Time: $elapsed_time"
    echo "Package Energy: $package_energy"
    echo "IA Energy: $ia_energy"
    echo "DRAM Energy: $dram_energy"

    # Split the subfolder based on the / character into two variables
    IFS='/' read -r subfolder1 subfolder2 <<< "$subfolder"

    number=$(echo "$filename" | cut -d'-' -f1)
    name_with_extension=$(echo "$filename" | cut -d'-' -f2-)
    name_without_extension=$(echo "$name_with_extension" | cut -d'.' -f1)

    # Append the extracted values to the output file, removing any unwanted characters
    echo "$number,$subfolder1,$subfolder2,$name_without_extension,$elapsed_time,$package_energy,$ia_energy,$dram_energy" >> "$output_file"
}

# Loop through the outer folders (e.g., "19-09-23T19-32-10", "20-09-23T02-30-52")
for outer_folder in */; do
    if [ -d "$outer_folder" ]; then
        # echo "Checking $outer_folder" # Debugging line

        # Determine the type ("mono" or "micro") based on the outer folder name
        if [[ "$outer_folder" == *"micro"* ]]; then
            folder_name="micro"
        elif [[ "$outer_folder" == *"mono"* ]]; then
            folder_name="mono"
        else
            folder_name="unknown"
        fi

        # Loop through the subfolders ("micro" or "mono") inside the outer folder
        for subfolder in "${outer_folder}"*; do
            if [ -d "$subfolder" ]; then
                echo "Checking $subfolder" # Debugging line

                # Loop through the CSV files in the subfolder
                for csv_file in "$subfolder"/*.csv; do
                    if [ -f "$csv_file" ]; then
                        extract_values "$folder_name" "$subfolder" "$csv_file"
                    fi
                done
            fi
        done
    fi
done

echo "Extraction complete. Results saved to $output_file"
