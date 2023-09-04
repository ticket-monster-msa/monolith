import argparse
import yaml
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
import time

def execute_actions(driver, actions):
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

            if action_type == 'navigate':
                driver.find_element(By.LINK_TEXT, value=target).click()

            elif action_type == 'select_dropdown':
                dropdown_element = driver.find_element(By.XPATH, value="//select")
                dropdown = Select(dropdown_element)
                dropdown.select_by_visible_text(target)

            elif action_type == 'click':
                driver.find_element(By.XPATH, value=f"//input[@value='{target}']").click()

            elif action_type == 'input':
                input_element = driver.find_element(By.XPATH, value=f"//input[@placeholder='{target}']")
                input_element.send_keys(value)
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
    driver.implicitly_wait(10)

    driver.get(config['website_url'])
    time.sleep(1)

    start_time = time.time()
    total_execution_time = execute_actions(driver, config['actions'])
    end_time = time.time()

    total_time = end_time - start_time + total_execution_time

    print(f"Total time taken: {total_time:.2f} seconds")

    time.sleep(5)
