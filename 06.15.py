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
---
import requests

url = "https://app.harness.io/v1/entities"

params = {
    "page": "0",
    "limit": "10",
    "sort": "string",
    "search_term": "string",
    "scopes": "string",
    "entity_refs": "string",
    "owned_by_me": "true",
    "favorites": "true",
    "kind": "string",
    "type": "string",
    "owner": "string",
    "lifecycle": "string",
    "tags": "string"
}

headers = {
    "Harness-Account": "string",
    "x-api-key": "YOUR_API_KEY_HERE"
}

response = requests.get(url, headers=headers, params=params)

print(f"Status Code: {response.status_code}")
print("Response Body:")
print(response.text)

yamls = '[{"identifier":"myadp_wallet_pass","entity_ref":"api:account.default.ADP_IDP_POV/myadp_wallet_pass","orgIdentifier":"default","org_name":"default","projectIdentifier":"ADP_IDP_POV","project_name":"ADP IDP","scope":"PROJECT","referenceType":"INLINE","kind":"api","type":"openapi","name":"MyADP Wallet Pass","description":"MyADP Wallet Pass","owner":"MyADP-Tuatara","tags":["myadp","tuatara"],"lifecycle":"production","metadata":{},"scorecards":{"average":null,"scores":[]},"yaml":"apiVersion: harness.io/v1\\nkind: API\\ntype: openapi\\nidentifier: myadp_wallet_pass\\nname: MyADP Wallet Pass\\nowner: MyADP-Tuatara\\norgIdentifier: default\\nprojectIdentifier: ADP_IDP_POV\\nspec:\\n  lifecycle: production\\n  definition: \' \'\\nmetadata:\\n  description: MyADP Wallet Pass\\n  tags:\\n  - myadp\\n  - tuatara\\n","starred":null,"status":[],"groups":[]},{"identifier":"offers_service","entity_ref":"api:account.default.ADP_IDP_POV/offers_service","orgIdentifier":"default","org_name":"default","projectIdentifier":"ADP_IDP_POV","project_name":"ADP IDP","scope":"PROJECT","referenceType":"INLINE","kind":"api","type":"openapi","name":"MyADP Offers Service","description":"Offers service","owner":"MyADP-Tuatara","tags":["myadp","tuatara"],"lifecycle":"production","metadata":{},"scorecards":{"average":null,"scores":[]},"yaml":"apiVersion: harness.io/v1\\nkind: API\\ntype: openapi\\nidentifier: offers_service\\nname: MyADP Offers Service\\nowner: MyADP-Tuatara\\norgIdentifier: default\\nprojectIdentifier: ADP_IDP_POV\\nspec:\\n  lifecycle: production\\n  definition: $text:https://bitbucket.es.ad.adp.com/projects/MSI/repos/myadp-offers-service/browse/swagger.yaml\\nmetadata:\\n  description: Offers service\\n  tags:\\n  - myadp\\n  - tuatara\\n","starred":null,"status":[],"groups":[]},{"identifier":"myadp_offers_service","entity_ref":"component:account.default.ADP_IDP_POV/myadp_offers_service","orgIdentifier":"default","org_name":"default","projectIdentifier":"ADP_IDP_POV","project_name":"ADP IDP","scope":"PROJECT","referenceType":"INLINE","kind":"component","type":"service","name":"Myadp Offers Service","description":"Myadp Offers Service.","owner":"MyADP-Tuatara","tags":["myadp","tuatara"],"lifecycle":"production","metadata":{"annotations":{"dynatrace.com/dynatrace-entity-id":"","sonarqube.org/project-key":"myadp-offers-service","grafana/overview-dashboard":"","opsgenie.com/component-selector":"status: open","grafana/dashboard-selector":"","grafana/alert-label-selector":"","opsgenie.com/team":"TestValue","jenkins.io/github-folder":"","jenkins.io/job-full-name":"","jira/project-key":"MYADP","backstage.io/techdocs-ref":"./"},"codeCoverageScore":"0.0"},"scorecards":{"average":45,"scores":[{"scorecard":"ADPIDP_Test","score":40,"total_checks":5,"passed_checks":2},{"scorecard":"Security_Scorecard","score":50,"total_checks":2,"passed_checks":1}]},"yaml":"apiVersion: harness.io/v1\\nkind: Component\\ntype: service\\nidentifier: myadp_offers_service\\nname: Myadp Offers Service\\nowner: MyADP-Tuatara\\norgIdentifier: default\\nprojectIdentifier: ADP_IDP_POV\\nspec:\\n  lifecycle: production\\n  providesApis:\\n  - offers_service\\n  consumesApis: []\\nmetadata:\\n  description: Myadp Offers Service.\\n  annotations:\\n    dynatrace.com/dynatrace-entity-id: \'\'\\n    sonarqube.org/project-key: myadp-offers-service\\n    grafana/overview-dashboard: \'\'\\n    opsgenie.com/component-selector: \'status: open\'\\n    grafana/dashboard-selector: \'\'\\n    grafana/alert-label-selector: \'\'\\n    opsgenie.com/team: TestValue\\n    jenkins.io/github-folder: \'\'\\n    jenkins.io/job-full-name: \'\'\\n    jira/project-key: MYADP\\n    backstage.io/techdocs-ref: ./\\n  codeCoverageScore: \'0.0\'\\n  tags:\\n  - myadp\\n  - tuatara\\n","starred":null,"status":[],"groups":[]},{"identifier":"myadp_wallet_pass","entity_ref":"component:account.default.ADP_IDP_POV/myadp_wallet_pass","orgIdentifier":"default","org_name":"default","projectIdentifier":"ADP_IDP_POV","project_name":"ADP IDP","scope":"PROJECT","referenceType":"INLINE","kind":"component","type":"service","name":"Myadp Wallet Pass","description":"MyAdp Wallet Pass","owner":"MyADP-Tuatara","tags":["myadp","tuatara"],"lifecycle":"production","metadata":{"annotations":{"dynatrace.com/dynatrace-entity-id":"","sonarqube.org/project-key":"","grafana/overview-dashboard":"","opsgenie.com/component-selector":"status: open","grafana/dashboard-selector":"","grafana/alert-label-selector":"","opsgenie.com/team":"","jenkins.io/github-folder":"myadp-wallet-pass","jenkins.io/job-full-name":"MSI","jira/project-key":"MYADP","backstage.io/techdocs-ref":"./"}},"scorecards":{"average":10,"scores":[{"scorecard":"ADPIDP_Test","score":20,"total_checks":5,"passed_checks":1},{"scorecard":"Security_Scorecard","score":0,"total_checks":2,"passed_checks":0}]},"yaml":"apiVersion: harness.io/v1\\nkind: Component\\ntype: service\\nidentifier: myadp_wallet_pass\\nname: Myadp Wallet Pass\\nowner: MyADP-Tuatara\\norgIdentifier: default\\nprojectIdentifier: ADP_IDP_POV\\nspec:\\n  lifecycle: production\\nmetadata:\\n  description: MyAdp Wallet Pass\\n  annotations:\\n    dynatrace.com/dynatrace-entity-id: \'\'\\n    sonarqube.org/project-key: \'\'\\n    grafana/overview-dashboard: \'\'\\n    opsgenie.com/component-selector: \'status: open\'\\n    grafana/dashboard-selector: \'\'\\n    grafana/alert-label-selector: \'\'\\n    opsgenie.com/team: \'\'\\n    jenkins.io/github-folder: myadp-wallet-pass\\n    jenkins.io/job-full-name: MSI\\n    jira/project-key: MYADP\\n    backstage.io/techdocs-ref: ./\\n  tags:\\n  - myadp\\n  - tuatara\\n","starred":null,"status":[],"groups":[]},{"identifier":"split_feature_evaluator","entity_ref":"component:account.default.ADP_IDP_POV/split_feature_evaluator","orgIdentifier":"default","org_name":"default","projectIdentifier":"ADP_IDP_POV","project_name":"ADP IDP","scope":"PROJECT","referenceType":"INLINE","kind":"component","type":"service","name":"MyADP Split Feature Evaluator","description":"MyADP Split Feature Evaluator.","owner":"MyADP-Tuatara","tags":["tuatara","myadp"],"lifecycle":"production","metadata":{"annotations":{"dynatrace.com/dynatrace-entity-id":"","sonarqube.org/project-key":"","grafana/overview-dashboard":"","opsgenie.com/component-selector":"status: open","grafana/dashboard-selector":"","grafana/alert-label-selector":"","opsgenie.com/team":"","jenkins.io/github-folder":"","jenkins.io/job-full-name":"","jira/project-key":"MYADP","backstage.io/techdocs-ref":"./"}},"scorecards":{"average":10,"scores":[{"scorecard":"ADPIDP_Test","score":20,"total_checks":5,"passed_checks":1},{"scorecard":"Security_Scorecard","score":0,"total_checks":2,"passed_checks":0}]},"yaml":"apiVersion: harness.io/v1\\nkind: Component\\ntype: service\\nidentifier: split_feature_evaluator\\nname: MyADP Split Feature Evaluator\\nowner: MyADP-Tuatara\\norgIdentifier: default\\nprojectIdentifier: ADP_IDP_POV\\nspec:\\n  lifecycle: production\\nmetadata:\\n  description: MyADP Split Feature Evaluator.\\n  annotations:\\n    dynatrace.com/dynatrace-entity-id: \'\'\\n    sonarqube.org/project-key: \'\'\\n    grafana/overview-dashboard: \'\'\\n    opsgenie.com/component-selector: \'status: open\'\\n    grafana/dashboard-selector: \'\'\\n    grafana/alert-label-selector: \'\'\\n    opsgenie.com/team: \'\'\\n    jenkins.io/github-folder: \'\'\\n    jenkins.io/job-full-name: \'\'\\n    jira/project-key: MYADP\\n    backstage.io/techdocs-ref: ./\\n  tags:\\n  - tuatara\\n  - myadp\\n","starred":null,"status":[],"groups":[]}]'

