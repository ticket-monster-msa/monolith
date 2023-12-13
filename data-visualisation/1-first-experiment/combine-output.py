import os
import csv

# Define the path to the output directory
output_dir = 'output'

# Initialize an empty list to store the data from all CSV files
combined_data = []

# Iterate through the subdirectories in the output directory
for subdir in os.listdir(output_dir):
    subdir_path = os.path.join(output_dir, subdir)
    if os.path.isdir(subdir_path):
        csv_file_path = os.path.join(subdir_path, 'test_results.csv')
        
        # Check if the CSV file exists in the current subdirectory
        if os.path.exists(csv_file_path):
            with open(csv_file_path, 'r', newline='') as csv_file:
                reader = csv.reader(csv_file)
                
                # Skip the header row if it's not the first file
                if combined_data:
                    next(reader)
                
                # Append the data from the current CSV file to the combined_data list
                combined_data.extend(row for row in reader)

# Define the path for the combined CSV file
combined_csv_path = os.path.join(output_dir, 'combined_test_results.csv')

# Write the combined data to the new CSV file
with open(combined_csv_path, 'w', newline='') as combined_csv_file:
    writer = csv.writer(combined_csv_file)
    writer.writerows(combined_data)

print(f'Combined CSV file saved to {combined_csv_path}')
