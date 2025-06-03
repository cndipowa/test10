import requests
import os

# Harness API setup
url = "https://app.harness.io/v1/entities"
params = {
    "orgIdentifier": "default",
    "projectIdentifier": "ADP_IDP_POV",
    "convert": "false",
    "dry_run": "false"
}
headers = {
    "Content-Type": "application/json",
    "Harness-Account": "JkY2eWMoTyop88bDTeyrqg",
    "x-api-key": "pat_JkY2eWMoTyop88bDTeyrqg.6d3807dfd615c41f5f0ad5e7.ji88c0Aqj2so4kppzqzK"
}

# Directory containing YAML files
yaml_dir = "./yamls"

# Loop through all YAML files and POST them
for filename in os.listdir(yaml_dir):
    if filename.endswith(".yaml") or filename.endswith(".yml"):
        with open(os.path.join(yaml_dir, filename), "r") as f:
            yaml_content = f.read()
            payload = {"yaml": yaml_content}
            response = requests.post(url, headers=headers, params=params, json=payload, verify=False)

            print(f"[{filename}] Status: {response.status_code}")
            print(f"[{filename}] Response: {response.text}")
