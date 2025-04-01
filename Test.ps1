$ErrorActionPreference = "Stop"

# Helper function to parse cert and check for wildcard entries
function Test-WildcardCert($pem) {
    if (-not $pem) { return $false }

    try {
        $pem = $pem -replace '-----BEGIN CERTIFICATE-----', '' `
                     -replace '-----END CERTIFICATE-----', '' `
                     -replace '\s', ''
        $certBytes = [Convert]::FromBase64String($pem)
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($certBytes)

        $subject = $cert.Subject
        if ($subject -match "CN=\*\..+") {
            return $true
        }

        # Check SANs if available (using OpenSSL if SAN parsing needed — native .NET lacks full SAN parsing)
        return $false  # SAN parsing omitted here; OpenSSL route would be needed

    } catch {
        Write-Warning "Failed to parse cert: $_"
        return $false
    }
}

# Get all routes from OpenShift
$routesJson = oc get routes --all-namespaces -o json | ConvertFrom-Json
$wildcardRoutes = @()

foreach ($route in $routesJson.items) {
    $ns = $route.metadata.namespace
    $name = $route.metadata.name
    $host = $route.spec.host
    $tls = $route.spec.tls

    $hostIsWildcard = $false
    $usesDefaultWildcard = $false
    $usesCustomWildcard = $false

    if ($host -match "^\*\..+") {
        $hostIsWildcard = $true
    }

    if ($hostIsWildcard -and -not $tls.certificate) {
        $usesDefaultWildcard = $true
    }

    if ($tls.destinationCACertificate) {
        $usesCustomWildcard = Test-WildcardCert $tls.destinationCACertificate
    }

    if ($hostIsWildcard -or $usesCustomWildcard) {
        $wildcardRoutes += [PSCustomObject]@{
            Namespace             = $ns
            Name                  = $name
            Host                  = $host
            UsesDefaultWildcard   = $usesDefaultWildcard
            UsesCustomWildcard    = $usesCustomWildcard
        }
    }
}

# Output CSV
$wildcardRoutes | Export-Csv -Path "wildcard_routes.csv" -NoTypeInformation
Write-Output "Done. Wildcard routes exported to wildcard_routes.csv"
