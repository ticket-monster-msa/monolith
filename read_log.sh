#!/bin/bash

# Parse command-line arguments
while getopts ":f:" opt; do
  case $opt in
    f)
      log_file=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check if the log file argument is provided
if [ -z "$log_file" ]; then
  echo "Log file path not provided. Usage: script_name -f <log_file>"
  exit 1
fi


# Array to store unique container names
container_names=()

# Array to store CPU usages for each container
container_cpu_usages=()

# Read the log file line by line
while IFS= read -r line; do
  container_name=$(echo "$line" | jq -r '.Name')
  cpu_usage=$(echo "$line" | jq -r '.CPUPerc')

  # Check if the container name already exists in the array
  if ! [[ " ${container_names[@]} " =~ " ${container_name} " ]]; then
    container_names+=("$container_name")
    container_cpu_usages+=("$cpu_usage")
  fi

done < "$log_file"

cpu_usages=()

# Display the container names and their corresponding CPU usages
echo "Container CPU Usages:"
for ((i=0; i<${#container_names[@]}; i++)); do
  container=${container_names[i]}
  cpu_usage=${container_cpu_usages[i]}

  echo "Container Name: $container"
  echo "CPU Usages: $cpu_usage"
  echo "----------------------"
done
