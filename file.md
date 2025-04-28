
# 1. Backup
oc get secret pull-secret -n openshift-config -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d > current-pull-secret.json

# 2. Edit file
vim current-pull-secret.json

# 3. Update secret
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=current-pull-secret.json

# 4. Validate
oc get secret pull-secret -n openshift-config -o json | jq '.data | keys'

# A test
echo "<password-or-token>" | docker login nexus.example.com -u "<username>" --password-stdin

# Restart machine-config-pools (Optional but Recommended)
If you are pulling from this registry during node provisioning, you might want to trigger a rollout so the nodes pick up the new pull secret:
oc delete pod -n openshift-machine-config-operator -l k8s-app=machine-config-controller
oc wait --for=condition=Updated mcp --all --timeout=10m

Usually, the nodes will re-pickup changes automatically, but a manual restart ensures no stale caches.

# 🧩 Wildcard Host Handling in Istio, Kubernetes, and OpenShift

## 🔄 Equivalents

| Istio Resource     | Purpose                              | Kubernetes Equivalent     | OpenShift Equivalent     |
|--------------------|--------------------------------------|---------------------------|---------------------------|
| `Gateway`          | L4/L6 ingress control                | `Ingress`, `LoadBalancer` | `Route`                   |
| `VirtualService`   | L7 routing (host/path matching)      | `Ingress`                 | `Route`                   |

---

## ✅ Wildcard Host Matching

### 🟣 Istio Example
```yaml
kind: VirtualService
spec:
  hosts:
    - "*.example.com"
```

### 🔵 Kubernetes Ingress Example
```yaml
kind: Ingress
spec:
  rules:
    - host: "*.example.com"
```

> Note: Left-most label wildcard only. Not all ingress controllers support this reliably.

### 🔴 OpenShift Route Example
```yaml
kind: Route
spec:
  host: "wildcard.example.com"
  wildcardPolicy: Subdomain
```

**Matches:**
- `foo.wildcard.example.com`
- `bar.foo.wildcard.example.com`

**Does NOT Match:**
- `wildcard.example.com` (needs separate route)
- `example.com`

---

## 🔎 Detecting Wildcard Hosts

### Istio VirtualServices
```bash
kubectl get virtualservices -A -o json | \
jq '.items[] | select(.spec.hosts[] | test("\\*")) | {ns: .metadata.namespace, name: .metadata.name, hosts: .spec.hosts}'
```

### Kubernetes Ingress
```bash
kubectl get ingress -A -o json | \
jq '.items[] | select(.spec.rules[]?.host | test("\\*"))'
```

### OpenShift Routes
```bash
oc get route -A -o json | \
jq '.items[] | select(.spec.wildcardPolicy == "Subdomain")'
```

---

## 🛠️ Remediation Suggestions

- Replace `*.<domain>` with specific hosts.
- Enforce admission policies using OPA/Gatekeeper.
- Monitor wildcard usage regularly.



Security & Compliance
Attack Surface Reduction: Wildcard routes expose multiple subdomains under a single DNS entry, which could be abused if not properly secured.

TLS/SSL Considerations: Wildcard certificates (often used with wildcard routes) have broader coverage, meaning a compromised certificate affects all subdomains.

Compliance Audits: Some security standards (e.g., PCI-DSS, FedRAMP) require strict control over publicly exposed endpoints.
