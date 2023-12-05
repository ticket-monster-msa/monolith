#!/bin/bash

# Check if any containers are running
containers_running=$(docker-compose -f monolith-compose.yml ps -q | awk '{print $1}')

if [[ -n "$containers_running" ]]; then
  # Some containers are running, shut it down
  echo "Shutting down any running containers..."
  docker-compose -f monolith-compose.yml down
  docker-compose -f microservice-compose.yml down
else
  # Neither monolith nor microservices containers are running
  echo "No running containers found."
fi