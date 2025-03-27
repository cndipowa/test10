routecount=$(oc get routes --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.tls.host}{"\n"}{end}' | grep '\*\.' | wc -l)
ingresscount=$(oc get ingresses --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.tls[*].hosts}{"\n"}{end}' | grep '\*\.' | wc -l)
total=$((routecount + ingresscount))
echo "Routes using wildcard certificates: $routecount"
echo "Ingresses using wildcard certificates: $ingresscount"
echo "Total routes and ingresses using wildcard certificates: $total"
