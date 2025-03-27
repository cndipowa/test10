oc get routes --all-namespaces -o json | jq -r '.items[] | select(.spec.tls?.certificate == "" or .spec.tls?.key == "") | "Namespace: (.metadata.namespace) Route: (.metadata.name)"'


kubectl get ingress --all-namespaces -o json | jq -r '.items[] | select(.spec.tls[]?.secretName | contains("") or test("wildcard")) | "Namespace: (.metadata.namespace) Ingress: (.metadata.name)"'

kubectl get ingress --all-namespaces -o json | jq -r '.items[] | select(any(.spec.tls[]?.secretName; . and (. | contains("") or test("wildcard")))) | "Namespace: (.metadata.namespace) Ingress: (.metadata.name) Secret: (.spec.tls[]?.secretName)"'
