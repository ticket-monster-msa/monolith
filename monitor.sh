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

echo "All containers are running. Monitoring starts in 5 seconds..."
sleep 5

echo "Monitoring CPU usage of Docker containers for $duration seconds..."


cpu_usages=()

# Loop through the container names and track CPU usage
for container in "${containers[@]}"; do
  echo "Monitoring CPU usage for container: $container"
  cpu_usage=$(docker stats --format "{{.CPUPerc}}" --no-stream "$container" | awk '{gsub("%",""); sum += $1} END {print sum}')
  cpu_usages+=("$cpu_usage")
done

# Calculate the average CPU usage
num_containers=${#containers[@]}
total_cpu_usage=0

for usage in "${cpu_usages[@]}"; do
  total_cpu_usage=$(echo "$total_cpu_usage + $usage" | bc)
done


average_cpu_usage=$(echo "scale=2; $total_cpu_usage / $num_containers" | bc)

# Calculate the energy consumption in watt-hours (Wh)
power_consumption=100  # Power consumption of the containers in watts
energy_consumption=$(echo "scale=2; $average_cpu_usage * $power_consumption * $duration / 3600" | bc)

echo "Average CPU usage: $average_cpu_usage%"
echo "Energy consumption during $duration seconds: $energy_consumption Wh"