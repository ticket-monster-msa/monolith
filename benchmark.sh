#!/bin/bash

# Enable "exit on error" behavior
set -e

./prereq.sh
pip install -r ./selenium/dependencies.txt

# Function to perform a single experiment
perform_experiment() {
  iterations="$1"

  datetime=$(date +"%d-%m-%yT%H-%M-%S")
  output_folder="./output/$datetime"
  mkdir -p "$output_folder"
  mkdir -p "$output_folder/mono"
  mkdir -p "$output_folder/micro"

  echo "---------------------------------------------"
  echo "Commencing Experiment and outputting to $output_folder"
  echo "---------------------------------------------"

  echo "Timestamp: $datetime"
  echo "Number of Iterations: $iterations"

  echo "Ticket Monster Experiment: $datetime" >> "$output_folder/test_results.csv"
  echo "Number of Iterations: $iterations" >> "$output_folder/test_results.csv"

  echo "---------------------------------------------"
  echo "Commencing Monolith Experiment"
  echo "---------------------------------------------"

  ./startup.sh --monolith

  sleep 5

 ./monitor.sh --monolith --iterations "$iterations" --output "$output_folder"

  ./shutdown.sh

  echo "---------------------------------------------"
  echo "Monolith Experiment Complete"
  echo "---------------------------------------------"

  sleep 3

  echo "---------------------------------------------"
  echo "Commencing Microservice Experiment"
  echo "---------------------------------------------"

  ./startup.sh --microservice

  sleep 5

  ./monitor.sh --microservice --iterations "$iterations" --output "$output_folder"

  ./shutdown.sh

  echo "---------------------------------------------"
  echo "Microservice Experiment Complete"
  echo "---------------------------------------------"
}

# Read the YAML configuration file using Python and loop through experiments
json_data=$(python -c '
import yaml
import json

data = yaml.safe_load(open("./workflows/experiment.yml", "r"))

# Convert the data to JSON for easy parsing in Bash
print(json.dumps(data["experiments"]))
')

# Use jq (a JSON processor) to convert the JSON data to a Bash array
experiments=($(echo "$json_data" | jq -r '.[] | "\(.iterations)"'))
echo "Experiments: ${experiments[@]}"

# exit 1;
# Loop through the Bash array and perform experiments
for experiment in "${experiments[@]}"; do
  iterations=$(echo "$experiment" | awk '{print $1}')

  echo "Performing experiment with Iterations: $iterations"
  perform_experiment "$iterations"  
done
