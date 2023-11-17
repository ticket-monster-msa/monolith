#!/bin/bash

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
monolith_frontend_workflow="./workflows/monolith/frontend.yml"
monolith_backend_workflow="./workflows/monolith/workload.json"
microservice_frontend_workflow="./workflows/microservice/frontend.yml"
microservice_backend_workflow="./workflows/microservice/workload.json"


# Output
output="./output"


# Enable "exit on error" behavior
set -e



# Function to perform a single experiment
perform_experiment() {
  ./prereq.sh \
    --mono_frontend="$monolith_frontend_workflow" \
    --mono_backend="$monolith_backend_workflow" \
    --micro_frontend="$microservice_frontend_workflow" \
    --micro_backend="$microservice_backend_workflow"

  pip install -r ./selenium/dependencies.txt

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

  ./startup.sh --monolith

  sleep 5

 ./monitor.sh \
  --monolith \
  --iterations="$iterations" \
  --workload_iterations="$workload_iterations" \
  --sleep_time="$sleep_time" \
  --output="$output_folder" \
  --sampling_frequency="$sampling_frequency" \
  --num_instances="$num_instances" \
  --frontend_workflow="$monolith_frontend_workflow" \
  --backend_workflow="$monolith_backend_workflow" \

  ./shutdown.sh

  exit;

  datetime=$(date +"%d-%m-%yT%H-%M-%S")
  echo "Monolith Experiment: $datetime" >> "$output_folder/test_results.csv"

  echo "---------------------------------------------"
  echo "Monolith Experiment Complete"
  echo "---------------------------------------------"

  sleep 3

  echo "---------------------------------------------"
  echo "Commencing Microservice Experiment"
  echo "---------------------------------------------"

  ./startup.sh --microservice

  sleep 5

  ./monitor.sh \
    --microservice \
    --iterations="$iterations" \
    --workload_iterations="$workload_iterations" \
    --sleep_time="$sleep_time" \
    --output="$output_folder" \
    --sampling_frequency="$sampling_frequency" \
    --num_instances="$num_instances" \
    --frontend_workflow="$microservice_frontend_workflow" \
    --backend_workflow="$microservice_backend_workflow" \

  ./shutdown.sh

  echo "---------------------------------------------"
  echo "Microservice Experiment Complete"
  echo "---------------------------------------------"
  
  datetime=$(date +"%d-%m-%yT%H-%M-%S")
  echo "Microservice Experiment: $datetime" >> "$output_folder/test_results.csv"

  pmset sleepnow
}

# Read the YAML configuration file using Python
json_data=$(python -c '
import yaml
import json

data = yaml.safe_load(open("./workflows/experiment.yml", "r"))

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


  echo "Performing experiment with Iterations: $iterations"
  echo "Workload Iterations: $workload_iterations"
  echo "Sleep Time: $sleep_time"
  echo "Output Folder: $output"
  echo "Sampling Frequency: $sampling_frequency"
  echo "Number of Instances: $num_instances"
  echo "Monolith Frontend workflow: $monolith_frontend_workflow"
  echo "Monolith Backend workflow: $monolith_backend_workflow"
  echo "Microservice Frontend workflow: $microservice_frontend_workflow"
  echo "Microservice Backend workflow: $microservice_backend_workflow"
  # Call your perform_experiment function with these variables
  perform_experiment

  break;
done

