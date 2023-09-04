echo "---------------------------------------------"
echo "Commencing Monolith Experiemnt"
echo "---------------------------------------------"

# ./monitor.sh --microservice 3 --iterations 3

# Get the current date and time in the format YYYYMMDD_HHMMSS
datetime=$(date +"%d-%m-%yT%H-%M-%S")

# Create the output folder with the current date and time
output_folder="./output/$datetime"
mkdir -p "$output_folder"

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