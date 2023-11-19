#!/bin/bash

./shutdown.sh

./startup.sh --monolith

sleep 10

num_instances=4

# Run the web crawler instances in parallel (example with num_instances=5)
for index in $(seq "$num_instances"); do
    python ./selenium/web_crawler.py ./selenium/monolith-config.yaml &
done

# Wait for all background processes to finish
wait

echo "Done"