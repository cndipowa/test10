import requests

url = "https://app.harness.io/v1/entities"
headers = {
    "Content-Type": "application/json",
    "Harness-Account": "string",
    "x-api-key": "YOUR_API_KEY_HERE"
}
params = {
    "orgIdentifier": "string",
    "projectIdentifier": "string",
    "convert": "false",
    "dry_run": "false"
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
    - my-sample
"""
}

response = requests.post(
    url,
    headers=headers,
    params=params,
    json=payload
)

# Print the response details
print(f"Status Code: {response.status_code}")
print("Headers:")
print(response.headers)
print("Response Body:")
print(response.text)
