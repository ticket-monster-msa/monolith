#!/bin/bash

# Enable "exit on error" behavior
set -e

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found."
  exit 1
fi

echo "Commencing startup"

# Check if Docker Compose directory path is provided and exists
if [[ -z "$2" || ! -d "${2#*=}" ]]; then
  echo "Docker Compose directory path not provided or directory does not exist. Usage: ./startup.sh [--monolith | --microservice] --application_dir_path=<path>"
  exit 1
fi

application_dir_path="${PROJECT_DIR}/${2#*=}"

if [[ "$1" == "--all" ]]; then
  # Execute monolithic setup using docker-compose.yml
  echo "Setting up both monolith and microservice systems..."
  docker-compose -f "$application_dir_path/docker-compose.yml" up -d --remove-orphans

  echo "Setup complete"
elif [[ "$1" == "--monolith" ]]; then
  # Execute monolithic setup using monolith-compose.yml
  echo "Running monolithic setup..."
  docker-compose -f "$application_dir_path/monolith-compose.yml" up -d --remove-orphans
elif [[ "$1" == "--microservice" ]]; then
  # Execute microservice setup using microservice-compose.yml
  echo "Running microservice setup..."
  docker-compose -f "$application_dir_path/microservice-compose.yml" up -d --remove-orphans
else
  # Invalid or no flag provided
   echo "Invalid flag or no flag provided. Usage: ./startup.sh [--monolith | --microservice] --application_dir_path=<path>"
  exit 1
fi

if [[ "$4" == "--monitor" ]]; then
  # Check if duration is provided as an argument
  if [[ -n "$5" && "$5" =~ ^[0-9]+$ ]]; then
    duration="$5"
  fi

  # Call the monitor script based on the same flag and duration
  echo "Running monitor script for $duration seconds..."
  $PROJECT_DIR/scripts/monitor.sh "$1" "$duration"
fi