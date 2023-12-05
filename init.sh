#!/bin/bash

# Get the current working directory
CURRENT_DIR="$(pwd)"

# Check if .env file exists
if [ -f .env ]; then
  # Check if PROJECT_DIR is already defined in .env
  if grep -q '^PROJECT_DIR=' .env; then
    # Update the existing PROJECT_DIR value using awk
    awk -v new_val="PROJECT_DIR=$CURRENT_DIR" '/^PROJECT_DIR=/ {$0=new_val} 1' .env > .env.tmp && mv .env.tmp .env
  else
    # Append PROJECT_DIR to the .env file    
    echo "" >> .env
    echo "PROJECT_DIR=$CURRENT_DIR" >> .env
  fi
else
  # Create a new .env file with PROJECT_DIR
  echo "Error: .env file not found. Create an .env file first"
fi

echo "Initialization complete. .env file updated with current directory."

# Execute the benchmark.sh script
./scripts/benchmark.sh

