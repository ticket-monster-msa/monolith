#!/bin/bash

$PROJECT_DIR/scripts/shutdown.sh

$PROJECT_DIR/scripts/startup.sh --monolith

sleep 10

num_instances=8

# Run the web crawler instances in parallel (example with num_instances=5)
for index in $(seq "$num_instances"); do
    python $PROJECT_DIR/selenium/web_crawler.py $PROJECT_DIR/selenium/monolith-config.yaml &
done

# Wait for all background processes to finish
wait

echo "Done"