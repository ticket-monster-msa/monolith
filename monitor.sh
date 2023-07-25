#!/bin/bash

if [[ "$1" == "--monolith" ]]; then
  containers=("univaq-masters-thesis-monolith-1")
  workflow_path="workflows/monolith"
elif [[ "$1" == "--microservice" ]]; then
  containers=("univaq-masters-thesis-tm-ui-v2-1" "univaq-masters-thesis-orders-service-1" "univaq-masters-thesis-backend-1")
  workflow_path="workflows/microservice"
else
  # Invalid or no flag provided
   echo "Invalid flag or no flag provided. Usage: ./monitor.sh [--monolith | --microservice] <duration (optional, defaults to 10s)>]"
  exit 1
fi

# Default monitoring duration in seconds
default_duration=10

# Accept the duration parameter as an integer
if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
  duration=$((10#$2))
else
  duration=$default_duration
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

# Get the current date and time in the format YYYYMMDD_HHMMSS
datetime=$(date +"%d-%m-%yT%H-%M-%S")

# Create the output folder with the current date and time
output_folder="./output/$datetime"
mkdir -p "$output_folder"

echo "All containers are running. Baseline Monitoring starts in 5 seconds..."
sleep 5

echo "---------------------------------------------"
echo "Commencing baseline monitoring for $duration seconds..."
echo "---------------------------------------------"

/Applications/Intel\ Power\ Gadget/PowerLog -duration "$duration" -resolution 1000 -file "$output_folder/baseline.csv"

echo "Baseline monitoring completed."

sleep 5

echo "---------------------------------------------"
echo "Commencing workgen & monitoring for $duration seconds..."
echo "---------------------------------------------"

wgen -w "$workflow_path"/workload.yml -a "$workflow_path"/apispec.yml -d "$duration"s
/Applications/Intel\ Power\ Gadget/PowerLog -duration "$duration" -resolution 1000 -file "$output_folder/monitor.csv"

echo "---------------------------------------------"
echo "Monitoring complete"
echo "---------------------------------------------"

echo "---------------------------------------------"
echo "Calculating output"
echo "---------------------------------------------"

# Read and extract values from the baseline.csv file
baseline_cumulative_package_mWh=$(awk -F'= ' '/Cumulative Package Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/baseline.csv")
baseline_cumulative_dram_mWh=$(awk -F'= ' '/Cumulative DRAM Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/baseline.csv")

cumulative_package_mWh=$(awk -F'= ' '/Cumulative Package Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/monitor.csv")
cumulative_dram_mWh=$(awk -F'= ' '/Cumulative DRAM Energy_0 \(mWh\)/ {gsub("\"", "", $2); print $2}' "$output_folder/monitor.csv")

# Display the extracted values
echo "Baseline Cumulative Package Energy_0 (mWh) = $baseline_cumulative_package_mWh"
echo "Baseline Cumulative DRAM Energy_0 (mWh) = $baseline_cumulative_dram_mWh"

echo "Cumulative Package Energy_0 (mWh) = $cumulative_package_mWh"
echo "Cumulative DRAM Energy_0 (mWh) = $cumulative_dram_mWh"


delta_package_mWh=$( echo "$cumulative_package_mWh" - "$baseline_cumulative_package_mWh" | bc)
delta_dram_mWh=$( echo "$cumulative_dram_mWh" - "$baseline_cumulative_dram_mWh" | bc)

total_energy_consumption_mWh=$( echo "$delta_package_mWh" + "$delta_dram_mWh" | bc)


echo "---------------------------------------------"
echo "Test results"
echo "---------------------------------------------"

# Display the calculated values
echo "Delta Package Energy_0 (mWh) = $delta_package_mWh"
echo "Delta DRAM Energy_0 (mWh) = $delta_dram_mWh"
echo "Total Energy Consumption (mWh) = $total_energy_consumption_mWh"
