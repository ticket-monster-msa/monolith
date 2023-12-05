#!/bin/bash

# Enable "exit on error" behavior
set -e

echo "---------------------------------------------"
echo "[REMOTE] - Checking prerequisites for experiment"
echo "---------------------------------------------"

# Initialize variables to store paths
frontend_workflow=""
backend_workflow=""
remote_execute=""
experiment_workflow=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --frontend_workflow=*)
      frontend_workflow="${1#*=}"
      ;;
    --backend_workflow=*)
      backend_workflow="${1#*=}"
      ;;
    --remote_execute=*)
      remote_execute="${1#*=}"
      ;;
    --experiment_workflow=*)
      experiment_workflow="${1#*=}"
      ;;
    *)
      echo "[REMOTE] - Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done


# Array of commands/applications to check
commands_to_check=(
    "newman:Newman (Postman command-line tool)"
    "python:Python"
)


for command_entry in "${commands_to_check[@]}"; do
    IFS=":" read -r command_name display_name <<< "$command_entry"

    if ! command -v "$command_name" &> /dev/null; then
        echo "[REMOTE] - $display_name is not installed. Please install $display_name."
        exit 1
    fi
    echo "[REMOTE] - $display_name is installed."
done


# Array of paths to check
paths_to_check=("$frontend_workflow" "$backend_workflow", "$experiment_workflow", "$remote_execute")

for path in "${paths_to_check[@]}"; do
    if [ ! -f "$path" ]; then
        echo "[REMOTE] - File $path does not exist."
        exit 1
    fi
    echo "[REMOTE] - File $path exists."
done

echo "---------------------------------------------"
echo "[REMOTE] - Prerequisites check complete"
echo "---------------------------------------------"