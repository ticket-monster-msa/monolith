#!/bin/bash
# How frequently Intel Power Gadget should sample (in milliseconds)
sampling_frequency=1000
# Default sleep time between monitoring
sleep_time=300
# Default number of iterations
default_iterations=1
# Iterations for workload generator
workload_iterations=50

# Checking parameters (whether its a monolith or microservice test)
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


# Accept the iterations parameter as an integer
if [[ -n "$3" && "$3" =~ ^[0-9]+$ ]]; then
  iterations=$((10#$3))
else
  iterations=$default_iterations
fi

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

sleep 10

echo "---------------------------------------------"
echo "Commencing monitoring script"
echo "---------------------------------------------"

output_folder="$5"
# mkdir -p "$output_folder/$name"

echo "---------------------------------------------"
echo "Testing web crawler to check duration of test"
echo "---------------------------------------------"

output=$(python ./selenium/web_crawler.py "$workflow_path"/frontend.yml)

# Extract time taken from Python Script output
total_time_taken=$(echo "$output" | awk '/Total time taken:/ {print $4}')
# Convert the extracted value to a floating-point number using bc
frontend_total_time=$(echo "$total_time_taken" | bc -l)
# Round the floating-point value up to the nearest integer using bc
# frontend_total_time=$(echo "scale=0; ($total_time_float + 0.5)/1" | bc)


echo "---------------------------------------------"
echo "Web Crawker test complete in $frontend_total_time seconds"
echo "---------------------------------------------"

echo "---------------------------------------------"
echo "Testing workload generator, check duration of test"
echo "---------------------------------------------"

# Run the command and capture the output
output=$(newman run "$workflow_path/workload.json" -n "$workload_iterations" 2>&1)
echo "$output"
# Extract and display the "total run duration"
duration_line=$(echo "$output" | grep -o "total run duration: [0-9.]*s")
if [ -z "$duration_line" ]; then
    echo "Total run duration not found in the output."
    exit 1  # Exit the script with an error status
fi
backend_total_time=$(echo "$duration_line" | awk '{print $4}' | sed 's/s//')


echo "---------------------------------------------"
echo "Workgen test complete in $backend_total_time"
echo "---------------------------------------------"

output_csv="$output_folder/test_results.csv"

./shutdown.sh
sleep 5

# Loop over the number of iterations
for (( i = 1; i <= iterations; i++ )); do
  prefix="["$name"-"$i"/"$((iterations))"]"
  ./startup.sh "$1"

  sleep 5

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

  echo "---------------------------------------------"
  echo "$prefix Commencing Iteration $i in $sleep_time seconds..."
  echo "---------------------------------------------"
  sleep "$sleep_time"


  echo "---------------------------------------------"
  echo "$prefix Commencing API baseline monitoring for $backend_total_time seconds..."
  echo "---------------------------------------------"

  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$backend_total_time" -resolution 1000 -file "$output_folder/$name/$i-api-baseline.csv"

  echo "$prefix Baseline monitoring completed."

  echo "$prefix Commencing monitoring in $sleep_time seconds..."

  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing workgen & monitoring for $backend_total_time seconds..."
  echo "---------------------------------------------"
  
  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$backend_total_time" -resolution 1000 -file "$output_folder/$name/$i-api-monitor.csv"
  output=$(newman run "$workflow_path/workload.json" -n "$workload_iterations" 2>&1)
  echo "$output"

  echo "---------------------------------------------"
  echo "$prefix API Monitoring complete"
  echo "---------------------------------------------"

  echo "$prefix Commencing frontend monitoring in $sleep_time seconds..."
  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing Frontend baseline monitoring for $frontend_total_time seconds..."
  echo "---------------------------------------------"

  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$frontend_total_time" -resolution 1000 -file "$output_folder/$name/$i-frontend-baseline.csv"

  echo "$prefix Frontend Baseline monitoring completed."

  echo "---------------------------------------------"
  echo "$prefix Commencing frontend monitoring in $sleep_time seconds..."
  echo "---------------------------------------------"

  sleep "$sleep_time"


  python ./selenium/web_crawler.py "$workflow_path"/frontend.yml
  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$frontend_total_time" -resolution 1000 -file "$output_folder/$name/$i-frontend-monitor.csv"


  echo "---------------------------------------------"
  echo "$prefix Monitoring complete"
  echo "---------------------------------------------"

  ./shutdown.sh
done 

echo "---------------------------------------------"
echo "Completed all $iterations iterations"
echo "---------------------------------------------"
