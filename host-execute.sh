#!/bin/bash

# Check the number of command-line arguments
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <experiment_type>"
  exit 1
fi

# Parse command-line argument
EXPERIMENT_TYPE=$1

# Check the experiment type and execute the remote script
case $EXPERIMENT_TYPE in
  "--frontend" | "--backend")
    REMOTE_SCRIPT_PATH="$SSH_PATH/remote-files/remote-execute.sh"  # Specify the path to the script on the remote machine
    ssh $SSH_USER@$SSH_HOST "bash -s" << EOF
      $REMOTE_SCRIPT_PATH
EOF
    ;;
  *)
    echo "Invalid experiment type. Usage: $0 [--frontend | --backend]"
    exit 1
    ;;
esac
