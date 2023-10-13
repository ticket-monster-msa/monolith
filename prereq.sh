#!/bin/bash

# Enable "exit on error" behavior
set -e

echo "---------------------------------------------"
echo "Checking prerequisites for experiment"
echo "---------------------------------------------"


# Array of commands/applications to check
commands_to_check=(
    "/Applications/Intel Power Gadget/PowerLog:PowerLog application"
    "node:Node.js"
    "npm:npm (Node Package Manager)"
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


# Check if the specified files exist
files_to_check=(
    "workflows/microservice/frontend.yml"
    "workflows/microservice/workload.json"
    "workflows/monolith/frontend.yml"
    "workflows/monolith/workload.json"
    "workflows/experiment.yml"
)

for file in "${files_to_check[@]}"; do
    if [ ! -f "$file" ]; then
        echo "File $file does not exist."
        exit 1
    fi
    echo "- File $file exists."
done

echo "---------------------------------------------"
echo "Prerequisites check complete"
echo "---------------------------------------------"