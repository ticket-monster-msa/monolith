#!/bin/bash

# Set default values
REMOTE_MACHINE_IP=""
LOCAL_SCRIPT_PATH=""
NUM_INSTANCES=5
WORKLOAD_ITERATIONS=10
BACKEND_WORKFLOW="/path/to/default_backend_workflow.json"
FRONTEND_WORKFLOW="/path/to/default_frontend_workflow.yml"
CURRENT_MACHINE_IP=""

# Function to run Selenium Frontend Experiment
run_selenium_frontend() {
  ssh user@$REMOTE_MACHINE_IP "bash -s" << EOF
    NUM_INSTANCES=$NUM_INSTANCES FRONTEND_WORKFLOW=$FRONTEND_WORKFLOW $LOCAL_SCRIPT_PATH
EOF
}

# Function to run Newman Backend Experiment
run_newman_backend() {
  ssh user@$REMOTE_MACHINE_IP "bash -s" << EOF
    NUM_INSTANCES=$NUM_INSTANCES WORKLOAD_ITERATIONS=$WORKLOAD_ITERATIONS BACKEND_WORKFLOW=$BACKEND_WORKFLOW $LOCAL_SCRIPT_PATH
EOF
}

# Check the number of command-line arguments
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <experiment_type> <remote_machine_ip> <current_machine_ip> [options]"
  exit 1
fi

# Parse command-line arguments
EXPERIMENT_TYPE=$1
REMOTE_MACHINE_IP=$2
CURRENT_MACHINE_IP=$3

# Process additional options
shift 3
while [ "$#" -gt 0 ]; do
  case "$1" in
    "--num-instances")
      NUM_INSTANCES=$2
      shift 2
      ;;
    "--workload-iterations")
      WORKLOAD_ITERATIONS=$2
      shift 2
      ;;
    "--backend-workflow")
      BACKEND_WORKFLOW=$2
      shift 2
      ;;
    "--frontend-workflow")
      FRONTEND_WORKFLOW=$2
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check the experiment type and execute the corresponding function
case $EXPERIMENT_TYPE in
  "--frontend")
    LOCAL_SCRIPT_PATH="/path/to/local/monitor.sh"
    run_selenium_frontend
    ;;
  "--backend")
    LOCAL_SCRIPT_PATH="/path/to/local/monitor.sh"
    run_newman_backend
    ;;
  *)
    echo "Invalid experiment type. Usage: $0 [--frontend | --backend] <remote_machine_ip> <current_machine_ip> [options]"
    exit 1
    ;;
esac
