#!/bin/bash

# Output file
output_file="extracted_values.csv"

# Function to extract the Cumulative Package Energy_0 (mWh) value
extract_value() {
    local folder="$1"
    local file="$2"
    local filename=$(basename "$file") # Get the filename without path
    
    local type=$(echo "$file" | cut -d '/' -f 2)    
    local number=$(echo "$filename" | grep -oE '^[0-9]+') # Extract the leading number
    local input_string=$(awk -F, '/Cumulative Package Energy_0 \(mWh\)/{print $NF}' "$file")
    local value=$(echo "$input_string" | cut -d '=' -f 2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # if [-n value]
    if [ -n "$value" ]; then
       local details_file="${folder}/test_results.csv"
        local duration=""
        local iterations=""

        # Extract duration and iterations from the test_results.csv file
        if [ -f "$details_file" ]; then
            duration=$(awk -F': ' '/Duration per API Test/{print $2}' "$details_file")
            iterations=$(awk -F': ' '/Number of Iterations/{print $2}' "$details_file")
        fi
        echo "${number},${type},${filename},${duration},${iterations},${value%?}" >> "$output_file"
        # echo "${number},${type},${filename},${duration},${iterations},${value%?}" 
    fi

}

# Function to extract experiment details from the test_results.csv file
extract_experiment_details() {
    local folder="$1"
    local details_file="${folder}/test_results.csv"
    if [ -f "$details_file" ]; then
        # Extract experiment details from the test_results.csv file
        experiment_name=$(awk -F ': ' '/Ticket Monster Experiment/{print $2}' "$details_file")
        duration_per_api_test=$(awk -F ': ' '/Duration per API Test/{print $2}' "$details_file")
        num_iterations=$(awk -F ': ' '/Number of Iterations/{print $2}' "$details_file")
        # echo "Outer Folder: $folder, Experiment: $experiment_name, Duration per API Test: $duration_per_api_test, Number of Iterations: $num_iterations"
        # echo "Outer Folder: $folder, Experiment: $experiment_name, Duration per API Test: $duration_per_api_test, Number of Iterations: $num_iterations" >> "$output_file"
    fi
}

# Loop through the outer folders (e.g., "11-09-23T13-22-18", "11-09-23T13-47-46", etc.)
for outer_folder in */; do
    if [ -d "$outer_folder" ]; then
        # Extract the outer folder name
        outer_folder_name=$(basename "$outer_folder")
        
        # Determine the type ("mono" or "micro") based on the inner folder name
        if [[ "$outer_folder" == *"/micro/"* ]]; then
            type="micro"
        elif [[ "$outer_folder" == *"/mono/"* ]]; then
            type="mono"
        else
            type="unknown"
        fi
        
        # Call the function to extract experiment details and add them to the header
        extract_experiment_details "$outer_folder"
        
        # Loop through the CSV files in the 'micro' or 'mono' directory for this outer folder
        for csv_file in "${outer_folder}"*/*.csv; do
            if [ -f "$csv_file" ]; then
                extract_value "$outer_folder_name" "$csv_file" "$type"
            fi
        done
    fi
done

echo "Extraction complete. Results saved to $output_file"
