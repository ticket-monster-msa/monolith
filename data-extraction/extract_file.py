import csv
import re
import os
import sys

def extract_info_from_test_results(test_results_file):
    info = {}

    # Read information from the test_results.csv file
    with open(test_results_file, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if "Ticket Monster Experiment" in line:
                info['experiment_date'] = line.split()[-1]
            elif "Workflow Path" in line:
                scenario_path = re.search(r'scenario-(.*?)/', line)
                if scenario_path:
                    info['scenario_path'] = scenario_path.group(1)
            elif "Number of Instances" in line:
                info['number_of_instances'] = line.split()[-1]
            elif "Sleep Time" in line:
                info['sleep_time'] = line.split()[-1]
            elif "Workload Iterations" in line:
                info['workload_iterations'] = line.split()[-1]
            elif "Number of Iterations" in line:
                info['number_of_iterations'] = line.split()[-1]
            elif "StartTimestamp" in line:
                info['start_timestamp'] = line.split()[-1]
            elif "Monolith Experiment" in line:
                info['monolith_experiment'] = line.split()[-1]
            elif "Microservice Experiment" in line:
                info['microservice_experiment'] = line.split()[-1]
            elif "mono Frontend Test Duration" in line:
                info['mono_frontend_test_duration'] = line.split()[-1]
            elif "mono Backend Test Duration" in line:
                info['mono_backend_test_duration'] = line.split()[-1]
            elif "micro Frontend Test Duration" in line:
                info['micro_frontend_test_duration'] = line.split()[-1]
            elif "micro Backend Test Duration" in line:
                info['micro_backend_test_duration'] = line.split()[-1]

    return info

def extract_data(input_file_path, output_folder_path, architecture):
    # Output file names
    normal_data_output_file_name = 'output.csv'
    cstate_data_output_file_name = 'cstate_output.csv'

    # Output file paths
    normal_data_output_file_path = os.path.join(output_folder_path, normal_data_output_file_name)
    cstate_data_output_file_path = os.path.join(output_folder_path, cstate_data_output_file_name)

    # Extract information from the test_results.csv file
    test_results_file = os.path.join(os.path.dirname(input_file_path),"../", "test_results.csv")
    info = extract_info_from_test_results(test_results_file)

    # Open input file for reading
    with open(input_file_path, 'r') as input_file:
        # Read all lines from the file
        lines = input_file.readlines()

    # Define a regex pattern for matching lines with timestamps
    timestamp_pattern = re.compile(r'\d{2}:\d{2}:\d{2}')

    # Find the index where the data section starts
    data_start_index = next((i for i, line in enumerate(lines) if timestamp_pattern.match(line.strip())), None)

    # Find the index where the C-State section starts
    cstate_start_index = next((i for i, line in enumerate(lines) if line.startswith('C-State    Resident      Count Latency')), None)

    # Extract header and data rows if the data section is found
    if data_start_index is not None:
        header = lines[data_start_index - 1].split()
        data_rows = [line.split() for line in lines[data_start_index:] if timestamp_pattern.match(line.strip())]
    else:
        header = []
        data_rows = []

    # Extract C-State information if found
    if cstate_start_index is not None:
        cstate_header = lines[cstate_start_index].split()
        cstate_data = [line.split() for line in lines[cstate_start_index + 1:]]
    else:
        cstate_header = []
        cstate_data = []

    # Write normal data to CSV file
    write_to_csv(normal_data_output_file_path, header, data_rows, input_file_path, architecture, info)

    # Write C-State data to CSV file
    write_to_csv(cstate_data_output_file_path, cstate_header, cstate_data, input_file_path, architecture, info, has_iteration=True)

    print(f'Data has been successfully written to {output_folder_path}')

def write_to_csv(file_path, header, data_rows, input_file_path, architecture, info, has_iteration=False):
    # Check if the file already exists
    file_exists = os.path.exists(file_path)

    # Open CSV file in append mode
    with open(file_path, 'a', newline='') as csv_file:
        # Create a CSV writer object
        csv_writer = csv.writer(csv_file)
        
        # Write header to CSV if the file is newly created
        if not file_exists:
            csv_writer.writerow(['InputFileName', 'Architecture', 'ExperimentDate', 'ScenarioPath',
                                'NumberOfInstances', 'SleepTime', 'WorkloadIterations',
                                'NumberOfIterations', 'StartTimestamp', 'MonolithExperiment',
                                'MicroserviceExperiment', 'MonoFrontendDuration', 'MonoBackendDuration', 'MicroFrontendDuration', 'MicroBackendDuration'] + header)
        
        # Write data to CSV if available
        if data_rows:
            iteration = 1
            for row in data_rows:
                if has_iteration:
                    csv_writer.writerow([os.path.basename(input_file_path), architecture,
                                        info.get('experiment_date', ''), info.get('scenario_path', ''),
                                        info.get('number_of_instances', ''), info.get('sleep_time', ''),
                                        info.get('workload_iterations', ''), info.get('number_of_iterations', ''),
                                        info.get('start_timestamp', ''), info.get('monolith_experiment', ''),
                                        info.get('microservice_experiment', ''), info.get('mono_frontend_test_duration'), info.get('mono_backend_test_duration'), info.get('micro_frontend_test_duration'), info.get('mono_backend_test_duration')] +
                                        [iteration] + row)
                    iteration += 1
                else:
                    csv_writer.writerow([os.path.basename(input_file_path), architecture,
                                        info.get('experiment_date', ''), info.get('scenario_path', ''),
                                        info.get('number_of_instances', ''), info.get('sleep_time', ''),
                                        info.get('workload_iterations', ''), info.get('number_of_iterations', ''),
                                        info.get('start_timestamp', ''), info.get('monolith_experiment', ''),
                                        info.get('microservice_experiment', ''), info.get('mono_frontend_test_duration'), info.get('mono_backend_test_duration'), info.get('micro_frontend_test_duration'), info.get('mono_backend_test_duration')] + row)

if __name__ == "__main__":
    # Check if the correct number of arguments is provided
    if len(sys.argv) != 3:
        print("Usage: python process_csv.py <input_file_path> <architecture>")
        sys.exit(1)

    # Get the input file path and architecture from the command line arguments
    input_file_path = sys.argv[1]
    architecture = sys.argv[2]

    # Ensure the output folder exists
    output_folder_path = './'  # Update with your desired output folder path
    os.makedirs(output_folder_path, exist_ok=True)

    # Extract and process data
    extract_data(input_file_path, output_folder_path, architecture)
