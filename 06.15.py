import requests

scope = "YOUR_scope_PARAMETER"
kind = "YOUR_kind_PARAMETER"
identifier = "YOUR_identifier_PARAMETER"
api_key = "YOUR_API_KEY_HERE"

url = f"https://app.harness.io/v1/entities/{scope}/{kind}/{identifier}"
params = {
    "orgIdentifier": "string",
    "projectIdentifier": "string"
}
headers = {
    "Content-Type": "application/json",
    "Harness-Account": "string",
    "x-api-key": api_key
}
payload = {
    "yaml": """apiVersion: harness.io/v1
kind: component
type: Service
identifier: my-sample-service
name: my-sample-service
owner: sample-owner
spec:
  lifecycle: experimental
  ownedBy:
    - group/sample-group
metadata:
  description: My Sample service.
  annotations:
    backstage.io/source-location: url:https://github.com/sample/sample/tree/main/harness/sample/
    backstage.io/techdocs-ref: dir:.
  links:
    - title: Website
      url: http://my-sample-website.com
  tags:
    - my-sample"""
}

response = requests.put(url, headers=headers, params=params, json=payload)

print(f"Status Code: {response.status_code}")
print("Response Body:")
print(response.text)
