#!/bin/bash

echo "Commencing startup"

if [[ "$1" == "--all" ]]; then
  # Execute monolithic setup using monolith-compose.yml
  echo "Setting up both monolith and microservice systems..."
  docker-compose up -d

  echo "Setup complete"
elif [[ "$1" == "--monolith" ]]; then
  # Execute monolithic setup using monolith-compose.yml
  echo "Running monolithic setup..."
  docker-compose -f monolith-compose.yml up -d
elif [[ "$1" == "--microservice" ]]; then
  # Execute microservice setup using microservice-compose.yml
  echo "Running microservice setup..."
  docker-compose -f microservice-compose.yml up -d
else
  # Invalid or no flag provided
   echo "Invalid flag or no flag provided. Usage: ./startup.sh [--monolith | --microservice] [--monitor <duration>]"
  exit 1
fi

if [[ "$2" == "--monitor" ]]; then
  # Check if duration is provided as an argument
  if [[ -n "$3" && "$3" =~ ^[0-9]+$ ]]; then
    duration="$3"
  fi

  # Call the monitor script based on the same flag and duration
  echo "Running monitor script for $duration seconds..."
  ./monitor.sh "$1" "$duration"
fi