import os
import requests
import yaml
import urllib.parse

HARNESS_API_KEY = os.getenv("HARNESS_API_KEY")  # or replace with your API key string
HARNESS_ACCOUNT_ID = "your_account_id"
ORG_IDENTIFIER = "your_org"
PROJECT_IDENTIFIER = "your_project"
YAML_FOLDER = "./yamls"

HEADERS = {
    "Content-Type": "application/json",
    "Harness-Account": HARNESS_ACCOUNT_ID,
    "x-api-key": HARNESS_API_KEY
}

def upload_yaml(filepath):
    with open(filepath, "r") as f:
        raw_yaml = f.read()
        parsed = yaml.safe_load(raw_yaml)

    scope = parsed.get("scope", "project")
    kind = parsed["kind"]
    identifier = parsed["identifier"]

    encoded_scope = urllib.parse.quote(scope, safe="")
    encoded_kind = urllib.parse.quote(kind, safe="")
    encoded_identifier = urllib.parse.quote(identifier, safe="")

    url = (
        f"https://app.harness.io/v1/entities/{encoded_scope}/{encoded_kind}/{encoded_identifier}"
    )
    params = {
        "orgIdentifier": ORG_IDENTIFIER,
        "projectIdentifier": PROJECT_IDENTIFIER
    }

    payload = {
        "yaml": raw_yaml
    }

    response = requests.put(url, headers=HEADERS, json=payload, params=params)

    print(f"▶️ PUT {url}")
    print(f"📄 File: {os.path.basename(filepath)}")
    print(f"🔁 Status: {response.status_code}")
    if response.status_code >= 400:
        print(f"❌ Error: {response.text}")
    else:
        print(f"✅ Success\n")

def main():
    for file in os.listdir(YAML_FOLDER):
        if file.endswith(".yaml") or file.endswith(".yml"):
            upload_yaml(os.path.join(YAML_FOLDER, file))

if __name__ == "__main__":
    main()
