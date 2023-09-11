import yaml
import json

data = yaml.safe_load(open("./workflows/experiments.yaml", "r"))

# Convert the data to JSON for easy parsing in Bash
print(json.dumps(data["experiments"]))