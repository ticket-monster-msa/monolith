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

echo "Monitoring CPU usage of Docker containers for $duration iterations..."
start_time=$(date +%s)

# Array to store CPU usage values
cpu_usages=()

# Function to collect CPU usage samples for all containers
collect_cpu_samples() {
  docker stats --format "table {{.Container}}\t{{.CPUPerc}}" --no-stream | tail -n +2
}

# Loop through while i is less than duration
i=0
while ((i < duration)); do
  echo "Collecting CPU usage samples (Iteration $((i + 1)))..."

  # Collect CPU usage samples
  cpu_samples=$(collect_cpu_samples)

  # Read CPU samples line by line and populate the array
  j=0
  while IFS= read -r line; do
    cpu_usage=$(awk '{print $2}' <<< "$line" | cut -d'%' -f1)
    cpu_usages+=("$cpu_usage")
    
    echo "[$(date "+%H:%M:%S")] Container ${containers[j]}: $cpu_usage%"
    ((j++))
  done <<< "$cpu_samples" 

  ((i++))
  sleep 1
done

# Calculate the average CPU usage
total_cpu_usage=0
num_samples=$((${#containers[@]} * duration))

for usage in "${cpu_usages[@]}"; do
  total_cpu_usage=$(echo "$total_cpu_usage + $usage" | bc)
done

average_cpu_usage=$(echo "scale=2; $total_cpu_usage / $num_samples" | bc)

# Calculate the energy consumption in watt-hours (Wh)
energy_consumption=$(echo "scale=2; $average_cpu_usage * $power_consumption * $duration / 3600" | bc)

echo "Average CPU usage: $average_cpu_usage%"
echo "Energy consumption through $duration iterations: $energy_consumption Wh"

# Calculate the total time taken
end_time=$(date +%s)
total_time=$((end_time - start_time))
echo "Total time taken: $total_time seconds"