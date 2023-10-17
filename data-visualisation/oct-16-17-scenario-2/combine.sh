#!/bin/bash

# Output file
output_file="extracted_values.csv"

# Create the header in the output file
echo "#,DateTime,Architecture,File,Total Elapsed Time (sec),Cumulative Package Energy_0 (mWh),Cumulative IA Energy_0 (mWh),Cumulative DRAM Energy_0 (mWh),Cumulative Package Energy_0 (Joules),Cumulative IA Energy_0 (Joules),Cumulative DRAM Energy_0 (Joules), Package Temperature_0 (C)" > "$output_file"

# Function to extract float values from a file
extract_values() {
    local folder="$1"
    local subfolder="$2"
    local file="$3"
    local filename=$(basename "$file") # Get the filename without path
    
    # Initialize variables for values
    local elapsed_time=""
    local package_energy_mwh=""
    local ia_energy_mwh=""
    local dram_energy_mwh=""
    local package_energy_joules=""
    local ia_energy_joules=""
    local dram_energy_joules=""
    
    # echo "Extracting values from: $folder/$subfolder/$filename" # Debugging line

    # Ensure consistent line endings with dos2unix
    dos2unix -q "$file"

    # Flag to indicate whether to start collecting Package Temperature values
    local collect_temperature_values=false
    
    # Loop through lines in the file
    while IFS= read -r line; do
        # Check for lines containing specific values
        if [[ $line =~ "Total Elapsed Time (sec) = " ]]; then
            elapsed_time=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative Package Energy_0 (mWh) = " ]]; then
            package_energy_mwh=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative Package Energy_0 (Joules) = " ]]; then
            package_energy_joules=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative IA Energy_0 (mWh) = " ]]; then
            ia_energy_mwh=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative IA Energy_0 (Joules) = " ]]; then
            ia_energy_joules=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative DRAM Energy_0 (mWh) = " ]]; then
            dram_energy_mwh=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
        elif [[ $line =~ "Cumulative DRAM Energy_0 (Joules) = " ]]; then
            dram_energy_joules=$(echo "$line" | awk -F ' = ' '{print $2}' | tr -d '"')
    fi
    done < "$file"


python_script=$(cat <<END
import pandas as pd

# Input CSV file
input_file = "$file"

# Read the CSV file into a pandas DataFrame
df = pd.read_csv(input_file)

# Extract values under the "Package Temperature_0(C)" header into a list
package_temperature_values = df["Package Temperature_0(C)"].dropna().tolist()

# Calculate the average of the collected values
average_temperature = sum(package_temperature_values) / len(package_temperature_values)

# Print the average temperature
print(average_temperature)
END
)


    # Execute the Python script and capture the output as a Bash variable
    average_temperature=$(python -c "$python_script")
    
    # Debugging lines to print extracted values
    echo "Elapsed Time: $elapsed_time"
    echo "Package Energy: $package_energy"
    echo "IA Energy: $ia_energy"
    echo "DRAM Energy: $dram_energy"
    echo "Average Package Temperature (C): $average_temperature"

    # Split the subfolder based on the / character into two variables
    IFS='/' read -r subfolder1 subfolder2 <<< "$subfolder"

    number=$(echo "$filename" | cut -d'-' -f1)
    name_with_extension=$(echo "$filename" | cut -d'-' -f2-)
    name_without_extension=$(echo "$name_with_extension" | cut -d'.' -f1)

    # Append the extracted values to the output file, removing any unwanted characters
    echo "$number,$subfolder1,$subfolder2,$name_without_extension,$elapsed_time,$package_energy_mwh,$ia_energy_mwh,$dram_energy_mwh,$package_energy_joules,$ia_energy_joules,$dram_energy_joules,$average_temperature" >> "$output_file"
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
