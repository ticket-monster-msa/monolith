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

# How frequently Intel Power Gadget should sample (in milliseconds)
sampling_frequency=1000
# Default sleep time between monitoring
sleep_time=5
# Default number of iterations
iterations=1
# Iterations for workload generator
workload_iterations=200
# Number of instances per experiment
num_instances=5

# Workflow files

monolith_frontend_workflow="$PROJECT_DIR/workflows/monolith/frontend.yml"
monolith_backend_workflow="$PROJECT_DIR/workflows/monolith/workload.json"
microservice_frontend_workflow="$PROJECT_DIR/workflows/microservice/frontend.yml"
microservice_backend_workflow="$PROJECT_DIR/workflows/microservice/workload.json"


# Output
output="$PROJECT_DIR/output"


# Enable "exit on error" behavior
set -e

# Function to prompt user for confirmation
confirm_experiment() {
  read -p "This experiment runs with the following configurations:
    - Number of Iterations: $iterations
    - Workload Iterations: $workload_iterations
    - Sleep Time: $sleep_time
    - Output Folder: $output
    - Sampling Frequency: $sampling_frequency
    - Number of Instances: $num_instances
    - Monolith Frontend workflow: $monolith_frontend_workflow
    - Monolith Backend workflow: $monolith_backend_workflow
    - Microservice Frontend workflow: $microservice_frontend_workflow
    - Microservice Backend workflow: $microservice_backend_workflow

Continue with the experiment? (y/n): " choice

  case "$choice" in
    y|Y )
      echo "Starting the experiment..."
      ;;
    n|N )
      echo "Experiment canceled by user. Exiting."
      exit 1
      ;;
    * )
      echo "Invalid choice. Please enter 'y' or 'n'."
      confirm_experiment
      ;;
  esac
}

# Function to perform a single experiment
perform_experiment() {
  $PROJECT_DIR/scripts/prereq.sh \
    --mono_frontend="$monolith_frontend_workflow" \
    --mono_backend="$monolith_backend_workflow" \
    --micro_frontend="$microservice_frontend_workflow" \
    --micro_backend="$microservice_backend_workflow"

  echo "---------------------------------------------"
  echo "Commencing remote setup"
  echo "---------------------------------------------"

  # check if remote files directory exists
  if [ ! -d "$PROJECT_DIR/remote-files" ]; then
    mkdir "$PROJECT_DIR"/remote-files
  fi

  # check if any existing files
  if [ "$(ls -A $PROJECT_DIR/remote-files)" ]; then
    echo "remote-files directory is not empty. Clearing directory..."
    rm -r $PROJECT_DIR/remote-files/*
  fi

  cp $monolith_frontend_workflow $PROJECT_DIR/remote-files/mono_frontend.yml
  cp $monolith_backend_workflow $PROJECT_DIR/remote-files/mono_workload.json
  cp $microservice_frontend_workflow $PROJECT_DIR/remote-files/micro_frontend.yml
  cp $microservice_backend_workflow $PROJECT_DIR/remote-files/micro_workload.json
  cp $PROJECT_DIR/selenium/web_crawler.py $PROJECT_DIR/remote-files
  cp $PROJECT_DIR/selenium/dependencies.txt $PROJECT_DIR/remote-files
  cp $PROJECT_DIR/workflows/experiment.yml $PROJECT_DIR/remote-files
  cp $PROJECT_DIR/scripts/remote-setup.sh $PROJECT_DIR/remote-files
  cp $PROJECT_DIR/scripts/remote-execute.sh $PROJECT_DIR/remote-files
  touch $PROJECT_DIR/remote-files/.env
  # Store the result of the command in the variable
  ipv4_address=$(hostname -I | cut -d' ' -f1)
  echo "HOST_IP=$ipv4_address" >> $PROJECT_DIR/remote-files/.env
  echo "HOST_URL_MONO=http://$ipv4_address:8080/ticket-monster" >> $PROJECT_DIR/remote-files/.env
  echo "HOST_URL_MICRO=http://$ipv4_address:5000" >> $PROJECT_DIR/remote-files/.env
  $PROJECT_DIR/scripts/host-setup.sh --files=$PROJECT_DIR/remote-files


  datetime=$(date +"%d-%m-%yT%H-%M-%S")
  output_folder="$output/$datetime"

  echo "$output"
  echo "$output_folder"
  
  mkdir -p "$output_folder"
  mkdir -p "$output_folder/mono"
  mkdir -p "$output_folder/micro"

  echo "---------------------------------------------"
  echo "Commencing Experiment and outputting to $output_folder"
  echo "---------------------------------------------"

  echo "Timestamp: $datetime"
  echo "Number of Iterations: $iterations"

  echo "Ticket Monster Experiment: $datetime" >> "$output_folder/test_results.csv"
  echo "Workflow Path: $monolith_frontend_workflow" >> "$output_folder/test_results.csv"
  echo "Number of Iterations: $iterations" >> "$output_folder/test_results.csv"
  echo "StartTimestamp: $datetime" >> "$output_folder/test_results.csv"
  echo "Workload Iterations: $workload_iterations" >> "$output_folder/test_results.csv" 
  echo "Sleep Time: $sleep_time" >> "$output_folder/test_results.csv"
  echo "Sampling Frequency: $sampling_frequency" >> "$output_folder/test_results.csv"
  echo "Number of Instances: $num_instances" >> "$output_folder/test_results.csv"

  echo "---------------------------------------------"
  echo "Commencing Monolith Experiment"
  echo "---------------------------------------------"
  $PROJECT_DIR/scripts/startup.sh --monolith

  sleep 5

$PROJECT_DIR/scripts/monitor.sh \
 --monolith \
 --iterations="$iterations" \
 --workload_iterations="$workload_iterations" \
 --sleep_time="$sleep_time" \
 --output="$output_folder" \
 --sampling_frequency="$sampling_frequency" \
 --num_instances="$num_instances" \
 --frontend_workflow="$monolith_frontend_workflow" \
 --backend_workflow="$monolith_backend_workflow" \

  $PROJECT_DIR/scripts/shutdown.sh

  datetime=$(date +"%d-%m-%yT%H-%M-%S")
  echo "Monolith Experiment: $datetime" >> "$output_folder/test_results.csv"

  echo "---------------------------------------------"
  echo "Monolith Experiment Complete"
  echo "---------------------------------------------"

  sleep 3

  echo "---------------------------------------------"
  echo "Commencing Microservice Experiment"
  echo "---------------------------------------------"

  $PROJECT_DIR/scripts/startup.sh --microservice

  sleep 5

  $PROJECT_DIR/scripts/monitor.sh \
    --microservice \
    --iterations="$iterations" \
    --workload_iterations="$workload_iterations" \
    --sleep_time="$sleep_time" \
    --output="$output_folder" \
    --sampling_frequency="$sampling_frequency" \
    --num_instances="$num_instances" \
    --frontend_workflow="$microservice_frontend_workflow" \
    --backend_workflow="$microservice_backend_workflow" \

  $PROJECT_DIR/scripts/shutdown.sh

  echo "---------------------------------------------"
  echo "Microservice Experiment Complete"
  echo "---------------------------------------------"
  
  datetime=$(date +"%d-%m-%yT%H-%M-%S")
  echo "Microservice Experiment: $datetime" >> "$output_folder/test_results.csv"

}

# Read the YAML configuration file using Python3
json_data=$(python3 -c '
import yaml
import json
import os

relative_file_path = os.path.join("workflows", "experiment.yml")

data = yaml.safe_load(open(relative_file_path, "r"))

# Filter and convert the data to JSON for easy parsing in Bash
filtered_data = [
    {
        "iterations": item["iterations"],
        "workload_iterations": item.get("workload_iterations", 100),
        "sleep_time": item.get("sleep_time", 2),
        "output_folder": item.get("output_folder", "output"),
        "sampling_frequency": item.get("sampling_frequency", 1000),
        "num_instances": item.get("num_instances", 1),
        "monolith_frontend_workflow": item.get("monolith_frontend_workflow", "./workflows/monolith/frontend.yml"),
        "monolith_backend_workflow": item.get("monolith_backend_workflow", "./workflows/monolith/workload.json"),
        "microservice_frontend_workflow": item.get("microservice_frontend_workflow", "./workflows/microservice/frontend.yml"),
        "microservice_backend_workflow": item.get("microservice_backend_workflow", "./workflows/microservice/workload.json")
    }
    for item in data.get("experiments", [])
]

print(json.dumps(filtered_data))
')

experiments=($(echo "$json_data" | jq -r '.[] | "\(.iterations) \(.workload_iterations) \(.sleep_time) \(.output_folder) \(.sampling_frequency) \(.num_instances) \(.monolith_frontend_workflow) \(.monolith_backend_workflow) \(.microservice_frontend_workflow) \(.microservice_backend_workflow)"'))



# Loop through the Bash array and perform experiments
for ((i = 0; i < ${#experiments[@]}; i += 5)); do
  iterations="${experiments[i]}"
  workload_iterations="${experiments[i+1]}"
  sleep_time="${experiments[i+2]}"
  output="${experiments[i+3]}"
  sampling_frequency="${experiments[i+4]}"
  num_instances="${experiments[i+5]}"
  monolith_frontend_workflow="${experiments[i+6]}"
  monolith_backend_workflow="${experiments[i+7]}"
  microservice_frontend_workflow="${experiments[i+8]}"
  microservice_backend_workflow="${experiments[i+9]}"
  
  # Call the confirm_experiment function
  confirm_experiment
  
  # Call the perform_experiment function with these variables
  perform_experiment

  break;
done

