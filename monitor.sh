#!/bin/bash

duration=10  # Monitoring duration in seconds
containers=("univaq-masters-thesis-tm-ui-v2-1" "univaq-masters-thesis-orders-service-1" "univaq-masters-thesis-backend-1")

# Based on MacBook Pro 2019 Thermal Design Power (TDP) - 45W.
power_consumption=45  # Power consumption of the containers in watts
# Represents power consumption beyond containers, Approximately 10 - 20 %
power_r=15  # Additional power consumption (e.g., server power)

echo "Monitoring CPU usage of Docker containers for $duration seconds..."

# Function to prettify the output table
prettify_table() {
  awk 'BEGIN { FS="\t"; OFS="\t" } { $1=sprintf("%-30s", $1); $2=sprintf("%-10s", $2); print }'
}

# Loop through the container names and monitor CPU usage
for container in "${containers[@]}"; do
  echo "Container: $container"
  docker stats --format "table {{.Container}}\t{{.CPUPerc}}" --no-stream "$container" | prettify_table
done

sleep "$duration"

# Calculate the energy consumption in kilowatt-hours (kWh)
total_power_consumption=0
for container in "${containers[@]}"; do
  cpu_usage=$(docker stats --format "{{.CPUPerc}}" --no-stream "$container" | awk '{gsub("%",""); sum += $1} END {print sum}')
  power_usage=$(echo "$cpu_usage * $power_consumption" | bc)
  total_power_consumption=$(echo "$total_power_consumption + $power_usage" | bc)
done

energy_consumption=$(echo "($total_power_consumption + $power_r)" | bc)

echo "Energy consumption: $energy_consumption Wh"
