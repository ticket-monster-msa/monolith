#!/bin/bash
# How frequently Intel Power Gadget should sample (in milliseconds)
sampling_frequency=1000
# Default sleep time between monitoring
sleep_time=3
# Default monitoring duration in seconds
default_duration=10
# Default number of iterations
default_iterations=1

# Initialize variables to hold cumulative values for average calculation
api_total_baseline_package_mWh=0
api_total_baseline_dram_mWh=0
api_total_package_mWh=0
api_total_dram_mWh=0

frontend_total_baseline_package_mWh=0
frontend_total_baseline_dram_mWh=0
frontend_total_package_mWh=0
frontend_total_dram_mWh=0

total_baseline_package_mWh=0
total_baseline_dram_mWh=0
total_package_mWh=0
total_dram_mWh=0

if [[ "$1" == "--monolith" ]]; then
  containers=("univaq-masters-thesis-monolith-1")
  workflow_path="workflows/monolith"
  name="mono"
elif [[ "$1" == "--microservice" ]]; then
  containers=("univaq-masters-thesis-tm-ui-v2-1" "univaq-masters-thesis-orders-service-1" "univaq-masters-thesis-backend-1")
  workflow_path="workflows/microservice"
  name="micro"
else
  # Invalid or no flag provided
  echo "Invalid flag or no flag provided. Usage: ./monitor.sh [--monolith | --microservice] <duration (optional, defaults to 10s)> [--iterations <number of iterations (optional, defaults to 1)>]"
  exit 1
fi

# Accept the duration parameter as an integer
if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
  duration=$((10#$2))
else
  duration=$default_duration
fi

# Accept the iterations parameter as an integer
if [[ -n "$4" && "$4" =~ ^[0-9]+$ ]]; then
  iterations=$((10#$4))
else
  iterations=$default_iterations
fi

echo "---------------------------------------------"
echo "Commencing monitoring script"
echo "---------------------------------------------"

echo "Waiting for containers..."
start_time=$(date +%s)
timeout=10

for container in "${containers[@]}"; do
  while ! docker container inspect "$container" >/dev/null 2>&1; do
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if (( elapsed_time > timeout )); then
      echo "Timeout: Containers did not start within $timeout seconds."
      exit 1
    fi
    sleep 1
  done
done

echo "All containers are running. "

output_folder="$6/$name"
mkdir -p "$output_folder/$name"

echo "---------------------------------------------"
echo "Checking for Python dependencies"
echo "---------------------------------------------"

pip install -r ./selenium/dependencies.txt

echo "---------------------------------------------"
echo "Testing web crawler to check duration of test"
echo "---------------------------------------------"

output=$(python3 ./selenium/web_crawler.py "$workflow_path"/frontend.yml)

# Extract time taken from Python Script output
total_time_taken=$(echo "$output" | awk '/Total time taken:/ {print $4}')
# Convert the extracted value to a floating-point number using bc
total_time_float=$(echo "$total_time_taken" | bc -l)
# Round the floating-point value up to the nearest integer using bc
total_time_rounded=$(echo "scale=0; ($total_time_float + 0.5)/1" | bc)

echo "---------------------------------------------"
echo "Web Crawker test complete in $total_time_taken seconds (rounded to $total_time_rounded seconds)"
echo "---------------------------------------------"

# Loop over the number of iterations
for (( i = 1; i <= iterations; i++ )); do
  prefix="["$i"/"$((iterations))"]"

  echo "---------------------------------------------"
  echo "$prefix Commencing Iteration $i in $sleep_time seconds"
  echo "---------------------------------------------"
  sleep "$sleep_time"


  echo "---------------------------------------------"
  echo "$prefix Commencing API baseline monitoring for $duration seconds..."
  echo "---------------------------------------------"

  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$duration" -resolution 1000 -file "$output_folder/api-baseline.csv"

  echo "$prefix Baseline monitoring completed."

  echo "$prefix Commencing monitoring in $sleep_time seconds..."

  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing workgen & monitoring for $duration seconds..."
  echo "---------------------------------------------"

  wgen -w "$workflow_path"/workload.yml -a "$workflow_path"/apispec.yml -d "$duration"s
  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$duration" -resolution 1000 -file "$output_folder/api-monitor.csv"

  echo "---------------------------------------------"
  echo "$prefix API Monitoring complete"
  echo "---------------------------------------------"

  echo "$prefix Commencing frontend monitoring in $sleep_time seconds..."
  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing Frontend baseline monitoring for $total_time_rounded seconds..."
  echo "---------------------------------------------"

  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$total_time_rounded" -resolution 1000 -file "$output_folder/frontend-baseline.csv"

  echo "$prefix Frontend Baseline monitoring completed."

  echo "---------------------------------------------"
  echo "$prefix Commencing frontend monitoring"
  echo "---------------------------------------------"

  python3 ./selenium/web_crawler.py "$workflow_path"/frontend.yml
  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$total_time_rounded" -resolution 1000 -file "$output_folder/frontend-monitor.csv"


  echo "---------------------------------------------"
  echo "$prefix Monitoring complete"
  echo "---------------------------------------------"

  echo "---------------------------------------------"
  echo "$prefix Calculating output"
  echo "---------------------------------------------"

  # Read and extract values from the baseline.csv file
  api_baseline_cumulative_package_mWh=$(awk -F'= ' '/Cumulative Package Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/api-baseline.csv")
  api_baseline_cumulative_dram_mWh=$(awk -F'= ' '/Cumulative DRAM Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/api-baseline.csv")
  
  api_cumulative_package_mWh=$(awk -F'= ' '/Cumulative Package Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/api-monitor.csv")
  api_cumulative_dram_mWh=$(awk -F'= ' '/Cumulative DRAM Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/api-monitor.csv")

  frontend_baseline_cumulative_package_mWh=$(awk -F'= ' '/Cumulative Package Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/frontend-baseline.csv")
  frontend_baseline_cumulative_dram_mWh=$(awk -F'= ' '/Cumulative DRAM Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/frontend-baseline.csv")

  frontend_cumulative_package_mWh=$(awk -F'= ' '/Cumulative Package Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/frontend-monitor.csv")
  frontend_cumulative_dram_mWh=$(awk -F'= ' '/Cumulative DRAM Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/frontend-monitor.csv")

  # Display the extracted values
  echo "$prefix Baseline API Cumulative Package Energy_0 (mWh) = $api_baseline_cumulative_package_mWh"
  echo "$prefix Baseline API Cumulative DRAM Energy_0 (mWh) = $api_baseline_cumulative_dram_mWh"
  
  echo "$prefix Baseline Frontend Cumulative Package Energy_0 (mWh) = $frontend_baseline_cumulative_package_mWh"
  echo "$prefix Baseline Frontend Cumulative DRAM Energy_0 (mWh) = $frontend_baseline_cumulative_dram_mWh"

  echo "$prefix Cumulative API Package Energy_0 (mWh) = $api_cumulative_package_mWh"
  echo "$prefix Cumulative API DRAM Energy_0 (mWh) = $api_cumulative_dram_mWh"
  
  echo "$prefix Cumulative Frontend Package Energy_0 (mWh) = $frontend_cumulative_package_mWh"
  echo "$prefix Cumulative Frontend DRAM Energy_0 (mWh) = $frontend_cumulative_dram_mWh"

  api_delta_package_mWh=$( echo "$api_cumulative_package_mWh" - "$api_baseline_cumulative_package_mWh" | bc)
  api_delta_dram_mWh=$( echo "$api_cumulative_dram_mWh" - "$api_baseline_cumulative_dram_mWh" | bc)
  
  frontend_delta_package_mWh=$( echo "$frontend_cumulative_package_mWh" - "$frontend_baseline_cumulative_package_mWh" | bc)
  frontend_delta_dram_mWh=$( echo "$frontend_cumulative_dram_mWh" - "$frontend_baseline_cumulative_dram_mWh" | bc)

  api_total_energy_consumption_mWh=$( echo "$api_delta_package_mWh" + "$api_delta_dram_mWh" | bc)
  frontend_total_energy_consumption_mWh=$( echo "$frontend_delta_package_mWh" + "$frontend_delta_dram_mWh" | bc)


  echo "---------------------------------------------"
  echo "$prefix Test results"
  echo "---------------------------------------------"

  # Display the calculated values
  echo "$prefix API Delta Package Energy_0 (mWh) = $api_delta_package_mWh"
  echo "$prefix API Delta DRAM Energy_0 (mWh) = $api_delta_dram_mWh"
  echo "$prefix API Total Energy Consumption (mWh) = $api_total_energy_consumption_mWh"
  
  echo "$prefix Frontend Delta Package Energy_0 (mWh) = $frontend_delta_package_mWh"
  echo "$prefix Frontend Delta DRAM Energy_0 (mWh) = $frontend_delta_dram_mWh"
  echo "$prefix Frontend Total Energy Consumption (mWh) = $frontend_total_energy_consumption_mWh"

  echo "$prefix Overall Total Energy Consumption (mWh) = $( echo "$api_total_energy_consumption_mWh" + "$frontend_total_energy_consumption_mWh" | bc)"

  # Update cumulative values for average calculation
  api_total_baseline_package_mWh=$( echo "$api_total_baseline_package_mWh" + "$api_baseline_cumulative_package_mWh" | bc)
  api_total_baseline_dram_mWh=$( echo "$api_total_baseline_dram_mWh" + "$api_baseline_cumulative_dram_mWh" | bc)
  api_total_package_mWh=$( echo "$api_total_package_mWh" + "$api_cumulative_package_mWh" | bc)
  api_total_dram_mWh=$( echo "$api_total_dram_mWh" + "$api_cumulative_dram_mWh" | bc)
  
  frontend_total_baseline_package_mWh=$( echo "$frontend_total_baseline_package_mWh" + "$frontend_baseline_cumulative_package_mWh" | bc)
  frontend_total_baseline_dram_mWh=$( echo "$frontend_total_baseline_dram_mWh" + "$frontend_baseline_cumulative_dram_mWh" | bc)
  frontend_total_package_mWh=$( echo "$frontend_total_package_mWh" + "$frontend_cumulative_package_mWh" | bc)
  frontend_total_dram_mWh=$( echo "$frontend_total_dram_mWh" + "$frontend_cumulative_dram_mWh" | bc)
done 

output_csv="$output_folder/test_results.csv"

echo "---------------------------------------------"
echo "Calculating overall test results across $iterations iterations"
echo "---------------------------------------------"


# Calculate average values
api_average_baseline_package_mWh=$( echo "$api_total_baseline_package_mWh" / "$iterations" | bc)
api_average_baseline_dram_mWh=$( echo "$api_total_baseline_dram_mWh" / "$iterations" | bc)
api_average_package_mWh=$( echo "$api_total_package_mWh" / "$iterations" | bc)
api_average_dram_mWh=$( echo "$api_total_dram_mWh" / "$iterations" | bc)
api_average_total_energy_consumption_mWh=$( echo "$api_average_package_mWh" + "$api_average_dram_mWh" | bc)

frontend_average_baseline_package_mWh=$( echo "$frontend_total_baseline_package_mWh" / "$iterations" | bc)
frontend_average_baseline_dram_mWh=$( echo "$frontend_total_baseline_dram_mWh" / "$iterations" | bc)
frontend_average_package_mWh=$( echo "$frontend_total_package_mWh" / "$iterations" | bc)
frontend_average_dram_mWh=$( echo "$frontend_total_dram_mWh" / "$iterations" | bc)
frontend_average_total_energy_consumption_mWh=$( echo "$frontend_average_package_mWh" + "$frontend_average_dram_mWh" | bc)

total_average_baseline_package_mWh=$( echo "$api_average_baseline_package_mWh" + "$frontend_average_baseline_package_mWh" | bc)
total_average_baseline_dram_mWh=$( echo "$api_average_baseline_dram_mWh" + "$frontend_average_baseline_dram_mWh" | bc)
total_average_package_mWh=$( echo "$api_average_package_mWh" + "$frontend_average_package_mWh" | bc)
total_average_dram_mWh=$( echo "$api_average_dram_mWh" + "$frontend_average_dram_mWh" | bc)
total_average_total_energy_consumption_mWh=$( echo "$api_average_total_energy_consumption_mWh" + "$frontend_average_total_energy_consumption_mWh" | bc)

echo "---------------------------------------------"
echo "Average Test results across $iterations iterations"
echo "---------------------------------------------"

# Output the calculated average values to a CSV file
echo "API Averages" >> "$output_csv"
echo "Average Baseline Cumulative Package Energy_0 (mWh) = $api_average_baseline_package_mWh" >> "$output_csv"
echo "Average Baseline Cumulative DRAM Energy_0 (mWh) = $api_average_baseline_dram_mWh" >> "$output_csv"
echo "Average Cumulative Package Energy_0 (mWh) = $api_average_package_mWh" >> "$output_csv"
echo "Average Cumulative DRAM Energy_0 (mWh) = $api_average_dram_mWh" >> "$output_csv"
echo "Average Delta Package Energy_0 (mWh) = $( echo "$api_average_package_mWh" - "$api_average_baseline_package_mWh" | bc)" >> "$output_csv"
echo "Average Delta DRAM Energy_0 (mWh) = $( echo "$api_average_dram_mWh" - "$api_average_baseline_dram_mWh" | bc)" >> "$output_csv"
echo "Average Total Energy Consumption (mWh) = $api_average_total_energy_consumption_mWh" >> "$output_csv"

echo "Frontend Averages" >> "$output_csv"
echo "Average Baseline Cumulative Package Energy_0 (mWh) = $frontend_average_baseline_package_mWh" >> "$output_csv"
echo "Average Baseline Cumulative DRAM Energy_0 (mWh) = $frontend_average_baseline_dram_mWh" >> "$output_csv"
echo "Average Cumulative Package Energy_0 (mWh) = $frontend_average_package_mWh" >> "$output_csv"
echo "Average Cumulative DRAM Energy_0 (mWh) = $frontend_average_dram_mWh" >> "$output_csv"
echo "Average Delta Package Energy_0 (mWh) = $( echo "$frontend_average_package_mWh" - "$frontend_average_baseline_package_mWh" | bc)" >> "$output_csv"
echo "Average Delta DRAM Energy_0 (mWh) = $( echo "$frontend_average_dram_mWh" - "$frontend_average_baseline_dram_mWh" | bc)" >> "$output_csv"
echo "Average Total Energy Consumption (mWh) = $frontend_average_total_energy_consumption_mWh" >> "$output_csv"

echo "Overall Averages" >> "$output_csv"
echo "Average Baseline Cumulative Package Energy_0 (mWh) = $total_average_baseline_package_mWh" >> "$output_csv"
echo "Average Baseline Cumulative DRAM Energy_0 (mWh) = $total_average_baseline_dram_mWh" >> "$output_csv"
echo "Average Cumulative Package Energy_0 (mWh) = $total_average_package_mWh" >> "$output_csv"
echo "Average Cumulative DRAM Energy_0 (mWh) = $total_average_dram_mWh" >> "$output_csv"
echo "Average Delta Package Energy_0 (mWh) = $( echo "$total_average_package_mWh" - "$total_average_baseline_package_mWh" | bc)" >> "$output_csv"
echo "Average Delta DRAM Energy_0 (mWh) = $( echo "$total_average_dram_mWh" - "$total_average_baseline_dram_mWh" | bc)" >> "$output_csv"
echo "Average Total Energy Consumption (mWh) = $total_average_total_energy_consumption_mWh" >> "$output_csv"

# Display the calculated average values

echo "Average Baseline Cumulative Package Energy_0 (mWh) = $total_average_baseline_package_mWh"
echo "Average Baseline Cumulative DRAM Energy_0 (mWh) = $total_average_baseline_dram_mWh"
echo "Average Cumulative Package Energy_0 (mWh) = $total_average_package_mWh"
echo "Average Cumulative DRAM Energy_0 (mWh) = $total_average_dram_mWh"
echo "Average Delta Package Energy_0 (mWh) = $( echo "$total_average_package_mWh" - "$total_average_baseline_package_mWh" | bc)"
echo "Average Delta DRAM Energy_0 (mWh) = $( echo "$total_average_dram_mWh" - "$total_average_baseline_dram_mWh" | bc)"

echo "API Average Energy Consumption (mWh) = $api_average_total_energy_consumption_mWh"
echo "Frontend Average Energy Consumption (mWh) = $frontend_average_total_energy_consumption_mWh"
echo "Total Average Energy Consumption (mWh) = $total_average_total_energy_consumption_mWh"