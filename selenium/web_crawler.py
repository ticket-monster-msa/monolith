import argparse
import yaml
import random
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.alert import Alert
from selenium.common.exceptions import TimeoutException  # Import TimeoutException
from selenium.common.exceptions import ElementClickInterceptedException
import time

max_retries = 3

def execute_actions(driver, actions, action_timeout=10):
    total_execution_time = 0

    for action in actions:
        retries = 0
        action_successful = False  # Flag to track if the action is successful

        while retries < max_retries and not action_successful:
            try:
                action_type = action['action']
                target = action.get('target')
                value = action.get('value')
                wait_time = action.get('wait', 0)  # Default wait time is 0 seconds
                print("\n [", retries, "]Executing action: ", action)

                if wait_time > 0:
                    time.sleep(wait_time)

            
                if action_type == 'navigate':
                    WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.LINK_TEXT, target))
                    ).click()
                    action_successful = True
            

                elif action_type == 'select_random_dropdown_option_by_xpath':
                    # Assuming you are now on the checkout page and need to select a random seating option
                    # Extract the target XPath from the YAML file
                    seating_dropdown_xpath = target

                    # Locate the seating dropdown element
                    seating_dropdown_element = WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.XPATH, seating_dropdown_xpath))
                    )

                    # Get all the options in the seating dropdown
                    seating_options = Select(seating_dropdown_element).options

                    # Filter out the default value
                    default_value = seating_dropdown_element.get_attribute('value')
                    non_default_options = [option.text for option in seating_options if option.get_attribute('value') != default_value]

                    # Check if there are non-default options available
                    if non_default_options:
                        # Select a random non-default seating option
                        selected_seating_option = random.choice(non_default_options)

                        # Perform the selection
                        seating_dropdown = Select(seating_dropdown_element)
                        seating_dropdown.select_by_visible_text(selected_seating_option)

                        action_successful = True
                    else:
                        print("No non-default options available.")

                elif action_type == 'click':
                    WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.XPATH, f"//input[@value='{target}']"))
                    ).click()
                    action_successful = True
          
                elif action_type == 'input':
                    input_element = WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.XPATH, f"//input[@placeholder='{target}']"))
                    )
                    input_element.send_keys(value)
                    action_successful = True

            except TimeoutException as te:
                print(f"Timeout executing action: {action}")
                print("Retrying...")
                driver.refresh()
                retries += 1
            except ElementClickInterceptedException as eci:
                print(f"Error executing action: {action}, {eci}")
                print("Element is not clickable, retrying...")
                driver.refresh()
                retries += 1
            except Exception as e:
                print("Error executing action: ", action)
                print(f"Error details: {e}")
                break  # Break if any other unexpected error occurs

        if not action_successful:
            print(f"Action failed after {max_retries} retries. Exiting script.")
            break  # If the action is not successful after max retries, exit the script

    return total_execution_time


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Execute actions based on YAML configuration.")
    parser.add_argument("config_path", help="Path to the YAML configuration file")

    args = parser.parse_args()

    with open(args.config_path, "r") as config_file:
        config = yaml.safe_load(config_file)

    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument("--incognito")
    chrome_options.add_argument(f"--window-size={config['window_size']}")

    driver = webdriver.Chrome(options=chrome_options)
    driver.implicitly_wait(15)

    driver.get(config['website_url'])
    time.sleep(1)

    start_time = time.time()
    total_execution_time = execute_actions(driver, config['actions'])
    end_time = time.time()

    total_time = end_time - start_time + total_execution_time

    print(f"Total time taken: {total_time:.2f} seconds")

    time.sleep(5)
