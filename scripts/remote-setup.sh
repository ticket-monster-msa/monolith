#!/bin/bash

# Enable "exit on error" behavior
set -e

echo "---------------------------------------------"
echo "[REMOTE] - Checking prerequisites for experiment"
echo "---------------------------------------------"

# Array of commands/applications to check
commands_to_check=(
    "newman:Newman (Postman command-line tool)"
    "python3:Python"
)

for command_entry in "${commands_to_check[@]}"; do
    IFS=":" read -r command_name display_name <<< "$command_entry"

    if ! command -v "$command_name" &> /dev/null; then
        echo "[REMOTE] - $display_name is not installed. Please install $display_name."
        exit 1
    fi
    echo "[REMOTE] - $display_name is installed."
done

# Install Python dependencies
echo "[REMOTE] - Installing Python dependencies..."
pip3 install -r dependencies.txt

echo "---------------------------------------------"
echo "[REMOTE] - Prerequisites check complete"
echo "---------------------------------------------"