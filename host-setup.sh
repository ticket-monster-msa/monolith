#!/bin/bash

# Default values
remote_addr=""
files_to_copy=""

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found."
  exit 1
fi


# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --files_to_copy=*)
      files_to_copy="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Check if required parameters are provided
if [[ -z "$files_to_copy" ]]; then
  echo "Usage: $0 --files_to_copy=<local_directory>"
  exit 1
fi

# Check for the following env variables; SSH_PASSWORD, SSH_HOST, SSH_USER, SSH_PATH
if [[ -z "$SSH_PASSWORD" || -z "$SSH_PATH" || -z "$SSH_USER" || -z "$SSH_HOST" ]]; then
  echo "Error: the following environment variables must be set: SSH_PASSWORD, SSH_HOST, SSH_USER, SSH_PATH"
  exit 1
fi


# Copy files to the remote machine
echo "Copying files to remote machine..."

ssh_uri="$SSH_USER@$SSH_HOST:$SSH_PATH"

expect -c "
  spawn rsync -avz -e ssh \"$files_to_copy\" \"$ssh_uri/\"
  expect \"password:\"
  send \"$SSH_PASSWORD\n\"
  interact
"

echo "Files copied to remote machine."
echo "Script executed successfully."