#!/bin/bash

# Enable "exit on error" behavior
set -e

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found."
  exit 1
fi

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
remote_machine_ip=""
remote_machine_user=""
remote_dir=""

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
    --remote_machine_ip=*)
      remote_machine_ip="${1#*=}"
      ;;
    --remote_machine_user=*)
      remote_machine_user="${1#*=}"
      ;;
    --remote_dir=*)
      remote_dir="${1#*=}"
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

sleep 10

echo "---------------------------------------------"
echo "Commencing monitoring script"
echo "---------------------------------------------"



echo "---------------------------------------------"
echo "Testing web crawler to check duration of test"
echo "---------------------------------------------"

# Record the start time
start_time=$(date +%s.%N)

# Run the web crawler from the remote machine
"$PROJECT_DIR"/scripts/host-execute.sh --frontend "$num_instances" --"$name"

# Wait for all background processes to finish
wait

# Calculate the total execution time
end_time=$(date +%s.%N)
# calculate total frontend time and add 5 seconds as a buffer
frontend_total_time=$(bc <<< "$end_time - $start_time + 5")
# check if its below 60 seconds and if so make it 60 seconds
if (( $(echo "$frontend_total_time < 60" | bc -l) )); then
  frontend_total_time=60
fi


echo "---------------------------------------------"
echo "Web Crawker test complete in $frontend_total_time seconds"
echo "---------------------------------------------"

echo "$name Frontend Test Duration: $frontend_total_time" >> "$output_folder/test_results.csv"

echo "---------------------------------------------"
echo "Testing workload generator, check duration of test"
echo "---------------------------------------------"

# Record the start time
start_time=$(date +%s.%N)

# Run the workload generator from the remote machine
$PROJECT_DIR/scripts/host-execute.sh --backend $workload_iterations --"$name"

# Wait for all background processes to finish
wait

# Calculate the total execution time
end_time=$(date +%s.%N)
# calculate total backend time and add 5 seconds as a buffer
backend_total_time=$(bc <<< "$end_time - $start_time + 5")
# check if its below 60 seconds and if so make it 60 seconds
if (( $(echo "$backend_total_time < 60" | bc -l) )); then
  backend_total_time=60
fi

echo "---------------------------------------------"
echo "Workgen test complete in $backend_total_time"
echo "---------------------------------------------"

echo "$name Backend Test Duration: $backend_total_time" >> "$output_folder/test_results.csv"


$PROJECT_DIR/scripts/shutdown.sh

sleep 5

# Loop over the number of iterations
for (( i = 1; i <= iterations; i++ )); do
  prefix="["$name"-"$i"/"$((iterations))"]"
  $PROJECT_DIR/scripts/startup.sh "$architecture"

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

  # /Applications/Intel\ Power\ Gadget/PowerLog -duration "$backend_total_time" -resolution 1000 -file "$output_folder/$name/$i-api-baseline.csv"
  # Run the powerstat command instead of Intel Power Gadget
  powerstat -DtfcRn 1 -d 2 $backend_total_time > $output_folder/$name/$i-api-baseline.csv

  echo "$prefix Baseline monitoring completed."

  echo "$prefix Commencing monitoring in $sleep_time seconds..."

  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing workgen & monitoring for $backend_total_time seconds..."
  echo "---------------------------------------------"
  
  # # Function to run newman command
  # run_newman() {
  #     output=$(newman run "$backend_workflow" -n "$workload_iterations" 2>&1)
  # }


  # /Applications/Intel\ Power\ Gadget/PowerLog -duration "$backend_total_time" -resolution 1000 -file "$output_folder/$name/$i-api-monitor.csv"
  powerstat -DtfcRn 1 -d 2 $backend_total_time > $output_folder/$name/$i-api-monitor.csv
  $PROJECT_DIR/scripts/host-execute.sh --backend $workload_iterations --"$name"

  wait


  echo "---------------------------------------------"
  echo "$prefix API Monitoring complete"
  echo "---------------------------------------------"

  echo "$prefix Commencing frontend monitoring in $sleep_time seconds..."
  sleep "$sleep_time"

  echo "---------------------------------------------"
  echo "$prefix Commencing Frontend baseline monitoring for $frontend_total_time seconds..."
  echo "---------------------------------------------"

  # /Applications/Intel\ Power\ Gadget/PowerLog -duration "$frontend_total_time" -resolution 1000 -file "$output_folder/$name/$i-frontend-baseline.csv"
  powerstat -DtfcRn 1 -d 2 $frontend_total_time > $output_folder/$name/$i-frontend-baseline.csv

  echo "$prefix Frontend Baseline monitoring completed."

  echo "---------------------------------------------"
  echo "$prefix Commencing frontend monitoring in $sleep_time seconds..."
  echo "---------------------------------------------"

  sleep "$sleep_time"


  # /Applications/Intel\ Power\ Gadget/PowerLog -duration "$frontend_total_time" -resolution 1000 -file "$output_folder/$name/$i-frontend-monitor.csv"
  powerstat -DtfcRn 1 -d 2 $frontend_total_time > $output_folder/$name/$i-frontend-monitor.csv
  $PROJECT_DIR/scripts/host-execute.sh --frontend $num_instances --"$name"

  wait

  echo "---------------------------------------------"
  echo "$prefix Monitoring complete"
  echo "---------------------------------------------"

  $PROJECT_DIR/scripts/shutdown.sh
done 

echo "---------------------------------------------"
echo "Completed all $iterations iterations"
echo "---------------------------------------------"
