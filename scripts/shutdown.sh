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
if [[ -z "$2" || ! -d "${2#*=}" ]]; then
  echo "Docker Compose directory path not provided or directory does not exist. Usage: ./shutdown.sh [--monolith | --microservice | --all] --application_dir_path=<path>"
  exit 1
fi

application_dir_path="${PROJECT_DIR}/${2#*=}"
containers_running=""

if [[ "$1" == "--monolith" ]]; then
  echo "Shutting down monolithic containers at $application_dir_path"
  containers_running=$(docker-compose -f "$application_dir_path/monolith-compose.yml" ps -q | awk '{print $1}')
elif [[ "$1" == "--microservice" ]]; then
  echo "Shutting down monolithic containers at $application_dir_path"
  containers_running=$(docker-compose -f "$application_dir_path/microservice-compose.yml" ps -q | awk '{print $1}')
elif [[ "$1" == "--all" ]]; then
  echo "Shutting down all containers at $application_dir_path"
  containers_running=$(docker-compose -f "$application_dir_path/monolith-compose.yml" ps -q | awk '{print $1}')
  containers_running+=$(docker-compose -f "$application_dir_path/microservice-compose.yml" ps -q | awk '{print $1}')
else
  # Invalid or no flag provided
   echo "Invalid flag or no flag provided. Usage: ./shutdown.sh [--monolith | --microservice | --all] --application_dir_path=<path>"
  exit 1
fi


# Check if any containers are running
# containers_running=$(docker-compose -f "$application_dir_path/monolith-compose.yml" ps -q | awk '{print $1}')

if [[ -n "$containers_running" ]]; then
  # Some containers are running, shut it down
  echo "Shutting down any running containers..."
  docker-compose -f "$application_dir_path/monolith-compose.yml" down
  docker-compose -f "$application_dir_path/microservice-compose.yml" down
else
  # Neither monolith nor microservices containers are running
  echo "No running containers found."
fi