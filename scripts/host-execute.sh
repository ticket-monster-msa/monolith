#!/bin/bash

# Enable "exit on error" behavior
set -e

# Check the number of command-line arguments
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <experiment_type>"
  exit 1
fi

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found."
  exit 1
fi

# Parse command-line argument
EXPERIMENT_TYPE=$1

# Check the experiment type and execute the remote script
case $EXPERIMENT_TYPE in
  "--frontend" | "--backend")
    REMOTE_SCRIPT_PATH="$SSH_PATH/remote-files/remote-execute.sh"  # Specify the path to the script on the remote machine
    SSH_COMMAND="ssh -i $SSH_KEY_PATH -o ConnectTimeout=10 $SSH_USER@$SSH_HOST \"bash -s\" <<EOF
      $REMOTE_SCRIPT_PATH $EXPERIMENT_TYPE
EOF"

    echo "Executing remote script..."
    eval "$SSH_COMMAND"

    # Check the exit status of the ssh command
    if [ $? -ne 0 ]; then
      echo "Error: SSH command failed. Exiting script."
      exit 1
    fi
    ;;
  *)
    echo "Invalid experiment type. Usage: $0 [--frontend | --backend]"
    exit 1
    ;;
esac
