#!/bin/bash

# Initialize variables
architecture=""
iterations=""
workload_iterations=""
sleep_time=""
output_folder=""
sampling_frequency=""
num_instances=5
frontend_workflow=""
backend_workflow=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --monolith|--microservice)
      architecture="$1"
      ;;
    --iterations=*)
      iterations="${1#*=}"
      ;;
    --workload_iterations=*)
      workload_iterations="${1#*=}"
      ;;
    --sleep_time=*)
      sleep_time="${1#*=}"
      ;;
    --output=*)
      output_folder="${1#*=}"
      ;;
    --sampling_frequency=*)
      sampling_frequency="${1#*=}"
      ;;
    --num_instances=*)
      num_instances="${1#*=}"
      ;;
    --frontend_workflow=*)
      frontend_workflow="${1#*=}"
      ;;
    --backend_workflow=*)
      backend_workflow="${1#*=}"
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

# Check for missing required options
if [[ -z "$architecture" || -z "$iterations" || -z "$workload_iterations" || -z "$sleep_time" || -z "$output_folder" || -z "$sampling_frequency" || -z "$frontend_workflow" || -z "$backend_workflow" ]]; then
  echo "All of the following options are required: --architecture (--monolith || --microservice), --iterations (number), --workload_iterations (number), --sleep_time (number in seconds), --output (relative directory path), --sampling_frequency (number, default is 1000), --frontend_workflow (relative directory path), --backend_workflow (relative directory path)" >&2
  exit 1
fi

# Use the extracted values in your script
echo "Architecture: $architecture"
echo "Iterations: $iterations"
echo "Workload Iterations: $workload_iterations"
echo "Sleep Time: $sleep_time"
echo "Output Folder: $output_folder"
echo "Sampling Frequency: $sampling_frequency"
echo "Number of Instances: $num_instances"
echo "Frontend Workflow: $frontend_workflow"
echo "Backend Workflow: $backend_workflow"

output_csv="$output_folder/test_results.csv"

# Checking parameters (whether its a monolith or microservice test)
if [[ "$architecture" == "--monolith" ]]; then
  containers=("univaq-masters-thesis-monolith-1")
  name="mono"
elif [[ "$architecture" == "--microservice" ]]; then
  containers=("univaq-masters-thesis-tm-ui-v2-1" "univaq-masters-thesis-orders-service-1" "univaq-masters-thesis-backend-1")
  name="micro"
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

sleep 30

echo "---------------------------------------------"
echo "Commencing monitoring script"
echo "---------------------------------------------"



echo "---------------------------------------------"
echo "Testing web crawler to check duration of test"
echo "---------------------------------------------"

# Record the start time
start_time=$(date +%s.%N)

# Run the web crawler instances in parallel (example with num_instances=5)
for index in $(seq "$num_instances"); do
    python ./selenium/web_crawler.py "$frontend_workflow" &
done

# Wait for all background processes to finish
wait

# Calculate the total execution time
end_time=$(date +%s.%N)
frontend_total_time=$(bc <<< "$end_time - $start_time")


echo "---------------------------------------------"
echo "Web Crawker test complete in $frontend_total_time seconds"
echo "---------------------------------------------"

echo "$name Frontend Test Duration: $frontend_total_time" >> "$output_folder/test_results.csv"

echo "---------------------------------------------"
echo "Testing workload generator, check duration of test"
echo "---------------------------------------------"

# Record the start time
start_time=$(date +%s.%N)

# Function to run newman command
run_newman() {
    output=$(newman run "$backend_workflow" -n "$workload_iterations" 2>&1)
}

# Run multiple instances of newman in parallel
for index in $(seq "$num_instances"); do
    run_newman &
done

# Wait for all background processes to finish
wait

# Calculate the total execution time
end_time=$(date +%s.%N)
backend_total_time=$(bc <<< "$end_time - $start_time")


echo "---------------------------------------------"
echo "Workgen test complete in $backend_total_time"
echo "---------------------------------------------"

echo "$name Backend Test Duration: $backend_total_time" >> "$output_folder/test_results.csv"


./shutdown.sh

sleep 5

# Loop over the number of iterations
for (( i = 1; i <= iterations; i++ )); do
  prefix="["$name"-"$i"/"$((iterations))"]"
  ./startup.sh "$architecture"

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
  
  # Function to run newman command
  run_newman() {
      output=$(newman run "$backend_workflow" -n "$workload_iterations" 2>&1)
  }


  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$backend_total_time" -resolution 1000 -file "$output_folder/$name/$i-api-monitor.csv"
  # Run multiple instances of newman in parallel
  for index in $(seq "$num_instances"); do
      run_newman &
  done

  wait


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

  # Define a function to run the web crawler
  run_web_crawler() {
      python ./selenium/web_crawler.py "$frontend_workflow"
  }

  # Run multiple instances in parallel
  for index in $(seq "$num_instances"); do
      run_web_crawler &
  done

  /Applications/Intel\ Power\ Gadget/PowerLog -duration "$frontend_total_time" -resolution 1000 -file "$output_folder/$name/$i-frontend-monitor.csv"

  wait

  echo "---------------------------------------------"
  echo "$prefix Monitoring complete"
  echo "---------------------------------------------"

  ./shutdown.sh
done 

echo "---------------------------------------------"
echo "Completed all $iterations iterations"
echo "---------------------------------------------"
