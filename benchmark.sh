# Experiement Setup


# Get the current date and time in the format YYYYMMDD_HHMMSS
datetime=$(date +"%d-%m-%yT%H-%M-%S")

# Create the output folder with the current date and time
output_folder="./output/$datetime"
mkdir -p "$output_folder"

echo "---------------------------------------------"
echo "Commencing Experiment and outputting to $output_folder"
echo "---------------------------------------------"

echo "Timestamp: $datetime"
echo "Duration per API Test: $2"
echo "Number of Iterations: $4"

echo "Ticket Monster Experimenet: $datetime" >> "$output_folder/test_results.csv"
echo "Duration per API Test: $2" >> "$output_folder/test_results.csv"
echo "Number of Iterations: $4" >> "$output_folder/test_results.csv"

echo "---------------------------------------------"
echo "Commencing Monolith Experiemnt"
echo "---------------------------------------------"


exit 1;
./startup.sh --monolith

sleep 5

./monitor.sh --monolith "$2" --iterations "$4" --output "$output_folder"

./shutdown.sh

echo "---------------------------------------------"
echo "Monolith Experiemnt Complete"
echo "---------------------------------------------"

sleep 3

echo "---------------------------------------------"
echo "Commencing Microservice Experiemnt"
echo "---------------------------------------------"

./startup.sh --microservice

sleep 5

./monitor.sh --microservice $1 --iterations $3 --output "$output_folder"

./shutdown.sh

echo "---------------------------------------------"
echo "Microservice Experiemnt Complete"
echo "---------------------------------------------"