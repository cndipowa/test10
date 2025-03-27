To pull a count of routes and ingresses that use wildcard certificates in OpenShift, you'll need to combine oc (OpenShift CLI) commands with some text processing. Here's a breakdown of how you can approach this, along with explanations:

Understanding the Challenge

Routes and Ingresses:
OpenShift Routes are OpenShift's own resource for exposing services.   
Kubernetes Ingresses are a standard Kubernetes resource for the same purpose.   
Wildcard Certificates: These certificates cover multiple subdomains (e.g., *.example.com).
Detection: You need to inspect the TLS configuration of routes and ingresses to find those using certificates with wildcard domain names.
Methods

Here's a strategy using oc and command-line tools:

1. Inspecting Routes:

Command:
oc get routes --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.tls.host}{"\n"}{end}'
This command retrieves all routes in all namespaces and extracts the namespace, name, and TLS host.
Filtering for Wildcards:
You can pipe the output of the previous command to grep to filter for lines containing *..
oc get routes --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.tls.host}{"\n"}{end}' | grep '\*\.'
Counting:
To get a count, pipe the output to wc -l.
oc get routes --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.tls.host}{"\n"}{end}' | grep '\*\.' | wc -l
2. Inspecting Ingresses:

Command:
oc get ingresses --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.tls[*].hosts}{"\n"}{end}'
This command retrieves all ingresses in all namespaces and extracts the namespace, name, and TLS hosts.
Filtering for Wildcards:
oc get ingresses --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.tls[*].hosts}{"\n"}{end}' | grep '\*\.'
Counting:
oc get ingresses --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.tls[*].hosts}{"\n"}{end}' | grep '\*\.' | wc -l
Important Considerations:

Certificate Secrets:
The commands above only check the hostnames in the route/ingress definitions. To get a more precise result, you might need to inspect the actual certificate secrets referenced by the routes/ingresses. 


Command to Get Routes and Ingresses Using Wildcard Certificates
Here are commands to find all routes (OpenShift) and ingresses (Kubernetes) that use wildcard certificates:

For OpenShift Routes
bash
Copy
oc get routes --all-namespaces -o json | jq -r '.items[] | select(.spec.tls?.certificate == "*" or .spec.tls?.key == "*") | "Namespace: \(.metadata.namespace) Route: \(.metadata.name)"'
For Kubernetes Ingresses
bash
Copy
kubectl get ingress --all-namespaces -o json | jq -r '.items[] | select(.spec.tls[]?.secretName | contains("*") or test("wildcard")) | "Namespace: \(.metadata.namespace) Ingress: \(.metadata.name)"'
Alternative for Ingresses (more thorough)
bash
Copy
kubectl get ingress --all-namespaces -o json | jq -r '.items[] | select(any(.spec.tls[]?.secretName; . and (. | contains("*") or test("wildcard")))) | "Namespace: \(.metadata.namespace) Ingress: \(.metadata.name) Secret: \(.spec.tls[]?.secretName)"'
Notes:
These commands:

Search across all namespaces

Look for routes/ingresses with TLS configuration

Filter for those using wildcard indicators ("*" or "wildcard" in secret names)

Output namespace and resource name

Wildcard certificates might be indicated by:

Literal "*" in certificate fields

Secret names containing "wildcard" or "*"

Other patterns your organization uses

You may need to adjust the patterns based on how wildcard certificates are named in your cluster.
