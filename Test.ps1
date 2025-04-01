$ErrorActionPreference = "Stop"

$ingressEntries = @()
$routeEntries = @()

### --- Ingresses ---
$ingresses = kubectl get ingress --all-namespaces -o json | ConvertFrom-Json

foreach ($ing in $ingresses.items) {
    $ns = $ing.metadata.namespace
    $name = $ing.metadata.name
    $rules = $ing.spec.rules
    $tls = $ing.spec.tls

    $tlsHosts = @{}
    foreach ($tlsEntry in $tls) {
        foreach ($host in $tlsEntry.hosts) {
            $tlsHosts[$host] = $tlsEntry.secretName
        }
    }

    foreach ($rule in $rules) {
        $host = $rule.host
        $secret = $tlsHosts[$host]

        $ingressEntries += [PSCustomObject]@{
            Namespace     = $ns
            IngressName   = $name
            Host          = $host
            TLS_Enabled   = if ($secret) { "Yes" } else { "No" }
            TLS_Secret    = $secret
        }
    }
}

### --- Routes ---
$routes = oc get routes --all-namespaces -o json | ConvertFrom-Json

foreach ($route in $routes.items) {
    $ns = $route.metadata.namespace
    $name = $route.metadata.name
    $host = $route.spec.host
    $tls = $route.spec.tls

    $tlsEnabled = if ($tls) { "Yes" } else { "No" }
    $termination = if ($tls) { $tls.termination } else { "" }

    $routeEntries += [PSCustomObject]@{
        Namespace     = $ns
        RouteName     = $name
        Host          = $host
        TLS_Enabled   = $tlsEnabled
        TLS_Termination = $termination
    }
}

# Export to two separate CSVs
$ingressEntries | Export-Csv -Path "ingresses.csv" -NoTypeInformation
$routeEntries   | Export-Csv -Path "routes.csv" -NoTypeInformation

Write-Output "Export complete: ingresses.csv and routes.csv created."
