$ErrorActionPreference = "Stop"

function Test-WildcardCert($pem) {
    if (-not $pem) { return $false }

    try {
        $pem = $pem -replace '-----BEGIN CERTIFICATE-----', '' `
                     -replace '-----END CERTIFICATE-----', '' `
                     -replace '\s', ''
        $bytes = [Convert]::FromBase64String($pem)
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($bytes)

        if ($cert.Subject -match "CN=\*\..+") {
            return $true
        }

        return $false
    } catch {
        Write-Warning "Certificate parsing failed: $_"
        return $false
    }
}

$ingressEntries = @()

$ingresses = kubectl get ingress --all-namespaces -o json | ConvertFrom-Json

foreach ($ing in $ingresses.items) {
    $ns = $ing.metadata.namespace
    $name = $ing.metadata.name
    $annotations = $ing.metadata.annotations
    $rules = $ing.spec.rules
    $tlsBlocks = $ing.spec.tls

    # Mapping of TLS secrets from spec
    $tlsSecrets = @{}
    foreach ($tls in $tlsBlocks) {
        foreach ($host in $tls.hosts) {
            $tlsSecrets[$host] = $tls.secretName
        }
    }

    foreach ($rule in $rules) {
        $host = $rule.host
        $tlsSecretName = $tlsSecrets[$host]
        $tlsWildcard = $false

        # Check TLS Secret from spec.tls
        if ($tlsSecretName) {
            try {
                $secret = kubectl get secret $tlsSecretName -n $ns -o json | ConvertFrom-Json
                $certData = $secret.data["tls.crt"]
                $tlsWildcard = Test-WildcardCert $certData
            } catch {
                Write-Warning "Failed to inspect TLS secret '$tlsSecretName' in '$ns'"
            }
        }

        # Check destination-ca-certificate-secret annotation
        $destSecretName = $annotations.'route.openshift.io/destination-ca-certificate-secret'
        $destWildcard = $false

        if ($destSecretName) {
            try {
                $destSecret = kubectl get secret $destSecretName -n $ns -o json | ConvertFrom-Json
                $destCertData = $destSecret.data["tls.crt"]
                $destWildcard = Test-WildcardCert $destCertData
            } catch {
                Write-Warning "Failed to inspect destination CA cert secret '$destSecretName' in '$ns'"
            }
        }

        $termination = $annotations.'route.openshift.io/termination'

        $ingressEntries += [PSCustomObject]@{
            Namespace             = $ns
            IngressName           = $name
            Host                  = $host
            TLS_Secret            = $tlsSecretName
            TLS_Secret_IsWildcard = $tlsWildcard
            DestCA_Secret         = $destSecretName
            DestCA_IsWildcard     = $destWildcard
            Termination           = $termination
        }
    }
}

# Export to CSV
$ingressEntries | Export-Csv -Path "ingresses.csv" -NoTypeInformation
Write-Output "Ingress inspection complete. Output written to ingresses.csv"
