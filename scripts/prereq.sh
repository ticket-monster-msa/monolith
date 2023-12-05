#!/bin/bash

# Enable "exit on error" behavior
set -e

echo "---------------------------------------------"
echo "Checking prerequisites for experiment"
echo "---------------------------------------------"

# Initialize variables to store paths
mono_frontend=""
mono_backend=""
micro_frontend=""
micro_backend=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mono_frontend=*)
      mono_frontend="${1#*=}"
      ;;
    --mono_backend=*)
      mono_backend="${1#*=}"
      ;;
    --micro_frontend=*)
      micro_frontend="${1#*=}"
      ;;
    --micro_backend=*)
      micro_backend="${1#*=}"
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done


# Array of commands/applications to check
commands_to_check=(
    "/Applications/Intel Power Gadget/PowerLog:PowerLog application"
    "newman:Newman (Postman command-line tool)"
    "python:Python"
    "docker:Docker"
)


for command_entry in "${commands_to_check[@]}"; do
    IFS=":" read -r command_name display_name <<< "$command_entry"

    if ! command -v "$command_name" &> /dev/null; then
        echo "$display_name is not installed. Please install $display_name."
        exit 1
    fi
    echo "- $display_name is installed."
done

if ! docker info &> /dev/null; then
    echo "Docker is not running. Please start Docker."
    exit 1
fi
echo "- Docker is running."


# Array of paths to check
paths_to_check=("$mono_frontend" "$mono_backend" "$micro_frontend" "$micro_backend")

for path in "${paths_to_check[@]}"; do
    if [ ! -f "$path" ]; then
        echo "File $path does not exist."
        exit 1
    fi
    echo "- File $path exists."
done

echo "---------------------------------------------"
echo "Prerequisites check complete"
echo "---------------------------------------------"