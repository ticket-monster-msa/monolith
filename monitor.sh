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
if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
  iterations=$((10#$2))
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

# Get the current date and time in the format YYYYMMDD_HHMMSS
datetime=$(date +"%d-%m-%yT%H-%M-%S")

# Create the output folder with the current date and time
output_folder="./output/$name-$datetime"
mkdir -p "$output_folder"

# Loop over the number of iterations
for (( i = 1; i <= iterations; i++ )); do
  prefix="["$i"/"$((iterations))"]"

  echo "---------------------------------------------"
  echo "$prefix Commencing Iteration $i in $sleep_time seconds"
  echo "---------------------------------------------"
  sleep "$sleep_time"


  echo "---------------------------------------------"
  echo "$prefix Commencing baseline monitoring for $duration seconds..."
  echo "---------------------------------------------"

  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$duration" -resolution 1000 -file "$output_folder/baseline.csv"

  echo "$prefix Baseline monitoring completed."

  echo "$prefix Commencing monitoring in $sleep_time seconds..."

  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing workgen & monitoring for $duration seconds..."
  echo "---------------------------------------------"

  wgen -w "$workflow_path"/workload.yml -a "$workflow_path"/apispec.yml -d "$duration"s
  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$duration" -resolution 1000 -file "$output_folder/monitor.csv"

  echo "---------------------------------------------"
  echo "$prefix Monitoring complete"
  echo "---------------------------------------------"

  echo "---------------------------------------------"
  echo "$prefix Calculating output"
  echo "---------------------------------------------"

  # Read and extract values from the baseline.csv file
  baseline_cumulative_package_mWh=$(awk -F'= ' '/Cumulative Package Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/baseline.csv")
  baseline_cumulative_dram_mWh=$(awk -F'= ' '/Cumulative DRAM Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/baseline.csv")

  cumulative_package_mWh=$(awk -F'= ' '/Cumulative Package Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/monitor.csv")
  cumulative_dram_mWh=$(awk -F'= ' '/Cumulative DRAM Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/monitor.csv")

  # Display the extracted values
  echo "$prefix Baseline Cumulative Package Energy_0 (mWh) = $baseline_cumulative_package_mWh"
  echo "$prefix Baseline Cumulative DRAM Energy_0 (mWh) = $baseline_cumulative_dram_mWh"

  echo "$prefix Cumulative Package Energy_0 (mWh) = $cumulative_package_mWh"
  echo "$prefix Cumulative DRAM Energy_0 (mWh) = $cumulative_dram_mWh"


  delta_package_mWh=$( echo "$cumulative_package_mWh" - "$baseline_cumulative_package_mWh" | bc)
  delta_dram_mWh=$( echo "$cumulative_dram_mWh" - "$baseline_cumulative_dram_mWh" | bc)

  total_energy_consumption_mWh=$( echo "$delta_package_mWh" + "$delta_dram_mWh" | bc)


  echo "---------------------------------------------"
  echo "$prefix Test results"
  echo "---------------------------------------------"

  # Display the calculated values
  echo "$prefix Delta Package Energy_0 (mWh) = $delta_package_mWh"
  echo "$prefix Delta DRAM Energy_0 (mWh) = $delta_dram_mWh"
  echo "$prefix Total Energy Consumption (mWh) = $total_energy_consumption_mWh"

  # Update cumulative values for average calculation
  total_baseline_package_mWh=$( echo "$total_baseline_package_mWh" + "$baseline_cumulative_package_mWh" | bc)
  total_baseline_dram_mWh=$( echo "$total_baseline_dram_mWh" + "$baseline_cumulative_dram_mWh" | bc)
  total_package_mWh=$( echo "$total_package_mWh" + "$cumulative_package_mWh" | bc)
  total_dram_mWh=$( echo "$total_dram_mWh" + "$cumulative_dram_mWh" | bc)
done 

output_csv="$output_folder/test_results.csv"

echo "---------------------------------------------"
echo "Calculating overall test results across $iterations iterations"
echo "---------------------------------------------"


# Calculate average values
average_baseline_package_mWh=$( echo "$total_baseline_package_mWh" / "$iterations" | bc)
average_baseline_dram_mWh=$( echo "$total_baseline_dram_mWh" / "$iterations" | bc)
average_package_mWh=$( echo "$total_package_mWh" / "$iterations" | bc)
average_dram_mWh=$( echo "$total_dram_mWh" / "$iterations" | bc)
average_total_energy_consumption_mWh=$( echo "$average_package_mWh" + "$average_dram_mWh" | bc)

echo "---------------------------------------------"
echo "Average Test results across $iterations iterations"
echo "---------------------------------------------"

# Output the calculated average values to a CSV file
echo "Average Baseline Cumulative Package Energy_0 (mWh) = $average_baseline_package_mWh" >> "$output_csv"
echo "Average Baseline Cumulative DRAM Energy_0 (mWh) = $average_baseline_dram_mWh" >> "$output_csv"
echo "Average Cumulative Package Energy_0 (mWh) = $average_package_mWh" >> "$output_csv"
echo "Average Cumulative DRAM Energy_0 (mWh) = $average_dram_mWh" >> "$output_csv"
echo "Average Delta Package Energy_0 (mWh) = $( echo "$average_package_mWh" - "$average_baseline_package_mWh" | bc)" >> "$output_csv"
echo "Average Delta DRAM Energy_0 (mWh) = $( echo "$average_dram_mWh" - "$average_baseline_dram_mWh" | bc)" >> "$output_csv"
echo "Average Total Energy Consumption (mWh) = $average_total_energy_consumption_mWh" >> "$output_csv"

# Display the calculated average values
echo "Average Baseline Cumulative Package Energy_0 (mWh) = $average_baseline_package_mWh"
echo "Average Baseline Cumulative DRAM Energy_0 (mWh) = $average_baseline_dram_mWh"
echo "Average Cumulative Package Energy_0 (mWh) = $average_package_mWh"
echo "Average Cumulative DRAM Energy_0 (mWh) = $average_dram_mWh"
echo "Average Delta Package Energy_0 (mWh) = $( echo "$average_package_mWh" - "$average_baseline_package_mWh" | bc)"
echo "Average Delta DRAM Energy_0 (mWh) = $( echo "$average_dram_mWh" - "$average_baseline_dram_mWh" | bc)"
echo "Average Total Energy Consumption (mWh) = $average_total_energy_consumption_mWh"