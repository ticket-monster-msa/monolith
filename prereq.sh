#!/bin/bash

# Enable "exit on error" behavior
set -e

echo "---------------------------------------------"
echo "Checking prerequisites for experiment"
echo "---------------------------------------------"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js."
    exit 1
fi

# Check if npm (Node Package Manager) is installed
if ! command -v npm &> /dev/null; then
    echo "npm (Node Package Manager) is not installed. Please install npm."
    exit 1
fi

# Check if Newman (Postman command-line tool) is installed
if ! command -v newman &> /dev/null; then
    echo "Newman is not installed. Please install Newman (Postman command-line tool)."
    exit 1
fi

# Check if Python is installed
if ! command -v python &> /dev/null; then
    echo "Python is not installed. Please install Python."
    exit 1
fi

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Docker is not running. Please start Docker."
    exit 1
fi

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
done

echo "---------------------------------------------"
echo "Prerequisites check complete"
echo "---------------------------------------------"
