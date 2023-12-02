#!/bin/bash

# Path to the configuration file on the host machine
CONFIG_FILE="config.json"

# Read parameters from the configuration file
REMOTE_MACHINE_IP=$(jq -r '.remote_machine_ip' "$CONFIG_FILE")
CURRENT_MACHINE_IP=$(jq -r '.current_machine_ip' "$CONFIG_FILE")
EXPERIMENT_TYPE=$(jq -r '.experiment_type' "$CONFIG_FILE")
NUM_INSTANCES=$(jq -r '.num_instances' "$CONFIG_FILE")
WORKLOAD_ITERATIONS=$(jq -r '.workload_iterations' "$CONFIG_FILE")
BACKEND_WORKFLOW=$(jq -r '.backend_workflow' "$CONFIG_FILE")
FRONTEND_WORKFLOW=$(jq -r '.frontend_workflow' "$CONFIG_FILE")

# Transfer the script and configuration file to the remote machine
scp host_script.sh "$REMOTE_MACHINE_IP":/path/to/remote/
scp "$CONFIG_FILE" "$REMOTE_MACHINE_IP":/path/to/remote/

# Remote execution of the script on the remote machine
ssh "$REMOTE_MACHINE_IP" "bash -s" << EOF
  # Path to the script and configuration file on the remote machine
  REMOTE_SCRIPT="/path/to/remote/host_script.sh"
  REMOTE_CONFIG_FILE="/path/to/remote/$CONFIG_FILE"
  
  # Execute the remote script with the configuration file
  bash "\$REMOTE_SCRIPT" --experiment-type "\$EXPERIMENT_TYPE" --num-instances "\$NUM_INSTANCES" --workload-iterations "\$WORKLOAD_ITERATIONS" --backend-workflow "\$BACKEND_WORKFLOW" --frontend-workflow "\$FRONTEND_WORKFLOW" --current-machine-ip "\$CURRENT_MACHINE_IP"
EOF
