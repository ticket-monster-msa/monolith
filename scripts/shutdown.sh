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

# Check if Docker Compose directory path is provided and exists
if [[ -z "$1" || ! -d "${1#*=}" ]]; then
  echo "Docker Compose directory path not provided or directory does not exist. Usage: ./startup.sh [--monolith | --microservice] --application_dir_path=<path>"
  exit 1
fi

application_dir_path="${PROJECT_DIR}/${1#*=}"

# Check if any containers are running
containers_running=$(docker-compose -f "$application_dir_path/monolith-compose.yml" ps -q | awk '{print $1}')

if [[ -n "$containers_running" ]]; then
  # Some containers are running, shut it down
  echo "Shutting down any running containers..."
  docker-compose -f "$application_dir_path/monolith-compose.yml" down
  docker-compose -f "$application_dir_path/microservice-compose.yml" down
else
  # Neither monolith nor microservices containers are running
  echo "No running containers found."
fi