curl -i -X POST \
  'https://app.harness.io/v1/entities?orgIdentifier=string&projectIdentifier=string&convert=false&dry_run=false' \
  -H 'Content-Type: application/json' \
  -H 'Harness-Account: string' \
  -H 'x-api-key: YOUR_API_KEY_HERE' \
  -d '{
    "yaml": "apiVersion: harness.io/v1\nkind: component\ntype: Service\nidentifier: my-sample-service\nname: my-sample-service\nowner: sample-owner\nspec:\n  lifecycle: experimental\n  ownedBy:\n    - group/sample-group\nmetadata:\n  description: My Sample service.\n  annotations:\n    backstage.io/source-location: url:https://github.com/sample/sample/tree/main/harness/sample/\n    backstage.io/techdocs-ref: dir:.\n  links:\n    - title: Website\n      url: http://my-sample-website.com\n  tags:\n    - my-sample\n"
  }'
