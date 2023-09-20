#!/bin/bash
# How frequently Intel Power Gadget should sample (in milliseconds)
sampling_frequency=1000
# Default sleep time between monitoring
sleep_time=300
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

output_folder="$6"
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

output_csv="$output_folder/test_results.csv"


echo "---------------------------------------------"
echo "Web Crawker test complete in $total_time_taken seconds (rounded to $total_time_rounded seconds)"
echo "---------------------------------------------"

# Loop over the number of iterations
for (( i = 1; i <= iterations; i++ )); do
  prefix="["$name"-"$i"/"$((iterations))"]"
  ./startup.sh "$1"

  echo "---------------------------------------------"
  echo "$prefix Commencing Iteration $i in $sleep_time seconds..."
  echo "---------------------------------------------"
  sleep "$sleep_time"


  echo "---------------------------------------------"
  echo "$prefix Commencing API baseline monitoring for $duration seconds..."
  echo "---------------------------------------------"

  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$duration" -resolution 1000 -file "$output_folder/$name/$i-api-baseline.csv"

  echo "$prefix Baseline monitoring completed."

  echo "$prefix Commencing monitoring in $sleep_time seconds..."

  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing workgen & monitoring for $duration seconds..."
  echo "---------------------------------------------"

  wgen -w "$workflow_path"/workload.yml -a "$workflow_path"/apispec.yml -d "$duration"s
  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$duration" -resolution 1000 -file "$output_folder/$name/$i-api-monitor.csv"

  echo "---------------------------------------------"
  echo "$prefix API Monitoring complete"
  echo "---------------------------------------------"

  echo "$prefix Commencing frontend monitoring in $sleep_time seconds..."
  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing Frontend baseline monitoring for $total_time_rounded seconds..."
  echo "---------------------------------------------"

  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$total_time_rounded" -resolution 1000 -file "$output_folder/$name/$i-frontend-baseline.csv"

  echo "$prefix Frontend Baseline monitoring completed."

  echo "---------------------------------------------"
  echo "$prefix Commencing frontend monitoring in $sleep_time seconds..."
  echo "---------------------------------------------"

  sleep "$sleep_time"


  python3 ./selenium/web_crawler.py "$workflow_path"/frontend.yml
  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$total_time_rounded" -resolution 1000 -file "$output_folder/$name/$i-frontend-monitor.csv"


  echo "---------------------------------------------"
  echo "$prefix Monitoring complete"
  echo "---------------------------------------------"

  ./shutdown.sh
done 

echo "---------------------------------------------"
echo "Completed all $iterations iterations"
echo "---------------------------------------------"
