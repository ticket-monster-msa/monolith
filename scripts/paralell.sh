#!/bin/bash

# Enable "exit on error" behavior
set -e

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found."
  exit 1
fi

$PROJECT_DIR/scripts/shutdown.sh --application_dir_path="$PROJECT_DIR/$application_dir_path"

$PROJECT_DIR/scripts/startup.sh --monolith --application_dir_path="$PROJECT_DIR/$application_dir_path"

sleep 10

num_instances=8

# Run the web crawler instances in parallel (example with num_instances=5)
for index in $(seq "$num_instances"); do
    python $PROJECT_DIR/selenium/web_crawler.py $PROJECT_DIR/selenium/monolith-config.yaml &
done

# Wait for all background processes to finish
wait

echo "Done"