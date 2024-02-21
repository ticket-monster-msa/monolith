#!/bin/bash

# Check the number of command-line arguments
if [ "$#" -ne 3 ]; then
  echo "[REMOTE] Usage: $0 [--frontend | --backend] <num_instances> [--mono | --micro]"
  exit 1
fi

# Parse command-line arguments
EXPERIMENT_TYPE=$1
NUM_INSTANCES=$2
ARCHITECTURE_FLAG=$3
architecture=${ARCHITECTURE_FLAG:2}

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "[REMOTE] Error: .env file not found."
  exit 1
fi

# Function for frontend experiment
run_frontend() {
  echo "[REMOTE] Running frontend function with $NUM_INSTANCES instances and $architecture ..."

  server_url=""
  if [ "$architecture" = "mono" ]; then
    echo "[REMOTE] Running monolith frontend"
    server_url=$HOST_URL_MONO
  else
    echo "[REMOTE] Running microservice frontend"
    server_url=$HOST_URL_MICRO
  fi
  # Add your frontend-specific commands here
  for index in $(seq "$NUM_INSTANCES"); do
    /usr/local/bin/python3 web_crawler.py "$architecture"_frontend.yml $HOST_IP &
  done

  wait
}

# Function for backend experiment
run_backend() {
  echo "[REMOTE] Running backend function with $NUM_INSTANCES instances and $architecture ..."
  # Add your backend-specific commands here
  server_url=""
  if [ "$architecture" = "mono" ]; then
    echo "[REMOTE] Running monolith backend"
    server_url=$HOST_URL_MONO
  else
    echo "[REMOTE] Running microservice backend"
    server_url=$HOST_URL_MICRO
  fi
  
  newman run "$architecture"_workload.json -n "$NUM_INSTANCES" --env-var "server_url=$server_url" --delay-request 200
  wait
}

# Check the experiment type and run the corresponding function
case $EXPERIMENT_TYPE in
  "--frontend")
    run_frontend
    ;;
  "--backend")
    run_backend
    ;;
  *)
    echo "[REMOTE] Invalid experiment type. Usage: $0 [--frontend | --backend] <num_instances> [--mono | --micro]"
    exit 1
    ;;
esac
