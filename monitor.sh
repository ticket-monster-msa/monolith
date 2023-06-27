#!/bin/bash

if [[ "$1" == "--monolith" ]]; then
  containers=("univaq-masters-thesis-monolith-1")
elif [[ "$1" == "--microservice" ]]; then
  containers=("univaq-masters-thesis-tm-ui-v2-1" "univaq-masters-thesis-orders-service-1" "univaq-masters-thesis-backend-1")
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

echo "Commencing monitoring script"

# Based on MacBook Pro 2019 Thermal Design Power (TDP) - 45W.
power_consumption=45  # Power consumption of the containers in watts
# Represents power consumption beyond containers, Approximately 10 - 20 %
power_r=15  # Additional power consumption (e.g., server power)

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

echo "All containers are running. Waiting for 5 seconds before starting monitoring..."
sleep 5

echo "Monitoring CPU usage of Docker containers for $duration seconds..."

# Function to prettify the output table
prettify_table() {
  awk 'BEGIN { FS="\t"; OFS="\t" } { $1=sprintf("%-30s", $1); $2=sprintf("%-10s", $2); print }'
}

# Store the start time
start_time=$(date +%s)

# Array to store CPU usage values for each container
cpu_usages=()

echo -e "\n"

# Start monitoring CPU usage for each container
for container in "${containers[@]}"; do

  (docker stats --format "{{.Container}}: {{.CPUPerc}}" --no-stream "$container" | \
    while read -r line; do
      # Extract the CPU usage value from the line
      cpu_usage=$(echo "$line" | awk '{gsub("%",""); print $NF}')

      # Clear the last line, move to the beginning of the line, insert a line break, and display updated CPU usage
    tput cuu 1 && tput el && echo -e "Container: $container - CPU usage: $cpu_usage%"
    done) &
done

# Wait for the specified duration
sleep "$duration"

# Terminate the background processes
pkill -P $$ docker

# Calculate the energy consumption in kilowatt-hours (kWh)
total_power_consumption=0
for container in "${containers[@]}"; do
  cpu_usage=$(docker stats --format "{{.CPUPerc}}" --no-stream "$container" | awk '{gsub("%",""); sum += $1} END {print sum}')
  power_usage=$(echo "$cpu_usage * $power_consumption * $duration / 100" | bc)
  total_power_consumption=$(echo "$total_power_consumption + $power_usage" | bc)
done

energy_consumption=$(echo "($total_power_consumption + $power_r)" | bc)

echo "Energy consumption during $duration seconds: $energy_consumption Wh"