#!/bin/bash

# Enable "exit on error" behavior
set -e

# Default values
remote_addr=""
files=""

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
    --files=*)
      files="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Check if required parameters are provided
if [[ -z "$files" ]]; then
  echo "Usage: $0 --files=<local_directory>"
  exit 1
fi

# Check for the following env variables; SSH_PASSWORD, SSH_HOST, SSH_USER, SSH_PATH
if [[ -z "$SSH_KEY_PATH" || -z "$SSH_PATH" || -z "$SSH_USER" || -z "$SSH_HOST" ]]; then
  echo "Error: the following environment variables must be set: SSH_KEY_PATH, SSH_HOST, SSH_USER, SSH_PATH"
  exit 1
fi

# Copy files to the remote machine
echo "Copying files to remote machine..."

ssh_uri="$SSH_USER@$SSH_HOST:$SSH_PATH"

rsync -avz -e "ssh -o ConnectTimeout=10 -i $SSH_KEY_PATH" "$files" "$ssh_uri/"

# Check the exit status of the rsync command
if [ $? -ne 0 ]; then
  echo "Error: rsync command failed. Exiting script."
  exit 1
fi

# execute the remote-setup.sh script on the remote machine
SSH_COMMAND="ssh -i $SSH_KEY_PATH -o ConnectTimeout=10 $SSH_USER@$SSH_HOST \"/bin/zsh -s\" <<EOF
      cd $SSH_PATH/remote-files/
      ./remote-setup.sh
      exit
EOF"

eval "$SSH_COMMAND"

echo "Files copied to remote machine."
echo "Script executed successfully."