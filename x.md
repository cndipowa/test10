# Get all Routes with TLS configuration
oc get routes --all-namespaces -o json | jq -r '.items[] | select(.spec.tls != null) | .metadata.namespace + "/" + .metadata.name'

# More detailed view of TLS Routes
oc get routes --all-namespaces -o wide | awk '$5 ~ /passthrough|reencrypt|edge/'

# Get all Routes with TLS configuration including details
oc get routes --all-namespaces -o jsonpath='{range .items[?(@.spec.tls)]}{.metadata.namespace}{"/"}{.metadata.name}{"\t"}{.spec.host}{"\t"}{.spec.tls.termination}{"\n"}{end}'

# Get all Ingresses with TLS configuration
oc get ingress --all-namespaces -o json | jq -r '.items[] | select(.spec.tls != null) | .metadata.namespace + "/" + .metadata.name'

# More detailed view of TLS Ingresses
oc get ingress --all-namespaces -o jsonpath='{range .items[?(@.spec.tls)]}{.metadata.namespace}{"/"}{.metadata.name}{"\t"}{.spec.rules[*].host}{"\t"}{.spec.tls[*].hosts}{"\n"}{end}'

echo "TLS Routes:"; oc get routes --all-namespaces -o jsonpath='{range .items[?(@.spec.tls)]}{.metadata.namespace}{"/"}{.metadata.name}{"\t"}{.spec.host}{"\t"}{.spec.tls.termination}{"\n"}{end}'; echo -e "\nTLS Ingresses:"; oc get ingress --all-namespaces -o jsonpath='{range .items[?(@.spec.tls)]}{.metadata.namespace}{"/"}{.metadata.name}{"\t"}{.spec.rules[*].host}{"\t"}{.spec.tls[*].hosts}{"\n"}{end}'
