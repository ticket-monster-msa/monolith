#!/bin/bash

# Function to perform a single experiment
perform_experiment() {
  duration="$1"
  iterations="$2"

  datetime=$(date +"%d-%m-%yT%H-%M-%S")
  output_folder="./output/$datetime"
  mkdir -p "$output_folder"

  echo "---------------------------------------------"
  echo "Commencing Experiment and outputting to $output_folder"
  echo "---------------------------------------------"

  echo "Timestamp: $datetime"
  echo "Duration per API Test: $duration"
  echo "Number of Iterations: $iterations"

  echo "Ticket Monster Experiment: $datetime" >> "$output_folder/test_results.csv"
  echo "Duration per API Test: $duration" >> "$output_folder/test_results.csv"
  echo "Number of Iterations: $iterations" >> "$output_folder/test_results.csv"

  echo "---------------------------------------------"
  echo "Commencing Monolith Experiment"
  echo "---------------------------------------------"

  ./startup.sh --monolith

  sleep 5

  ./monitor.sh --monolith "$duration" --iterations "$iterations" --output "$output_folder"

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

  ./monitor.sh --microservice "$duration" --iterations "$iterations" --output "$output_folder"

  ./shutdown.sh

  echo "---------------------------------------------"
  echo "Microservice Experiment Complete"
  echo "---------------------------------------------"
}

# Read the YAML configuration file using Python and loop through experiments
json_data=$(python -c '
import yaml
import json

data = yaml.safe_load(open("./workflows/experiments.yaml", "r"))

# Convert the data to JSON for easy parsing in Bash
print(json.dumps(data["experiments"]))
')

# Use jq (a JSON processor) to convert the JSON data to a Bash array
experiments=($(echo "$json_data" | jq -r '.[] | "\(.duration)"'))
echo "Experiments: ${experiments[@]}"

# exit 1;
# Loop through the Bash array and perform experiments
for experiment in "${experiments[@]}"; do
  duration=$(echo "$experiment" | awk '{print $1}')
  iterations=10
  
  echo "Performing experiment with Duration: $duration, Iterations: $iterations"
  perform_experiment "$duration" "$iterations"
  
done