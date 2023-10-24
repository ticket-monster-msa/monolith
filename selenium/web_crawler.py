import argparse
import yaml
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.alert import Alert
from selenium.common.exceptions import TimeoutException  # Import TimeoutException
import time

def execute_actions(driver, actions, action_timeout=10):
    total_execution_time = 0

    for action in actions:
        try:
            action_type = action['action']
            target = action.get('target')
            value = action.get('value')
            wait_time = action.get('wait', 0)  # Default wait time is 0 seconds
            print("\nExecuting action: ", action)

            if wait_time > 0:
                time.sleep(wait_time)

            try:
                if action_type == 'navigate':
                    WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.LINK_TEXT, target))
                    ).click()

                elif action_type == 'select_dropdown':
                    dropdown_element = WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.XPATH, "//select"))
                    )
                    dropdown = Select(dropdown_element)
                    dropdown.select_by_visible_text(target)

                elif action_type == 'click':
                    WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.XPATH, f"//input[@value='{target}']"))
                    ).click()

                elif action_type == 'click-target':
                    WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.CSS_SELECTOR, target))
                    ).click()

                elif action_type == 'confirm-alert':
                    WebDriverWait(driver, action_timeout).until(EC.alert_is_present()).accept()

                elif action_type == 'input':
                    input_element = WebDriverWait(driver, action_timeout).until(
                        EC.presence_of_element_located((By.XPATH, f"//input[@placeholder='{target}']"))
                    )
                    input_element.send_keys(value)

            except TimeoutException as te:
                print(f"Timeout executing action: {action}, {te}")
        except Exception as e:
            print("Error executing action: ", action)
            print(f"Error details: {e}")

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
