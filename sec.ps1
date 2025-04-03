<#
.SYNOPSIS
    Finds Kubernetes secrets containing certificates that are about to expire.
.DESCRIPTION
    This script scans all or specified namespaces for Kubernetes secrets of type 'kubernetes.io/tls',
    extracts the certificates, and checks their expiration dates.
.PARAMETER Namespace
    The Kubernetes namespace to search in. Defaults to all namespaces if not specified.
.PARAMETER DaysUntilExpiration
    The threshold in days to consider a certificate as "about to expire". Defaults to 30 days.
.PARAMETER OutputFormat
    The output format: 'Table', 'List', or 'JSON'. Defaults to 'Table'.
.EXAMPLE
    .\Find-ExpiringK8sCerts.ps1 -Namespace "prod" -DaysUntilExpiration 60
.EXAMPLE
    .\Find-ExpiringK8sCerts.ps1 -OutputFormat JSON | ConvertFrom-Json
#>

param(
    [string]$Namespace = "",
    [int]$DaysUntilExpiration = 30,
    [ValidateSet('Table', 'List', 'JSON')]
    [string]$OutputFormat = 'Table'
)

# Check if kubectl is available
if (-not (Get-Command "kubectl" -ErrorAction SilentlyContinue)) {
    Write-Error "kubectl is not found in PATH. Please install Kubernetes CLI."
    exit 1
}

# Get current date for comparison
$currentDate = Get-Date

# Get secrets from Kubernetes
$secretCommand = if ($Namespace) {
    "kubectl get secrets -n $Namespace --field-selector type=kubernetes.io/tls -o json"
} else {
    "kubectl get secrets --all-namespaces --field-selector type=kubernetes.io/tls -o json"
}

try {
    $secrets = Invoke-Expression $secretCommand | ConvertFrom-Json
} catch {
    Write-Error "Failed to get secrets from Kubernetes: $_"
    exit 1
}

$results = @()

foreach ($secret in $secrets.items) {
    # Base64 decode the certificate data
    try {
        $certBytes = [System.Convert]::FromBase64String($secret.data.'tls.crt')
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certBytes)
    } catch {
        Write-Warning "Failed to parse certificate in secret $($secret.metadata.name) in namespace $($secret.metadata.namespace): $_"
        continue
    }

    # Calculate days until expiration
    $daysLeft = ($cert.NotAfter - $currentDate).Days

    if ($daysLeft -le $DaysUntilExpiration) {
        $result = [PSCustomObject]@{
            Namespace      = $secret.metadata.namespace
            SecretName     = $secret.metadata.name
            Subject        = $cert.Subject
            Issuer         = $cert.Issuer
            NotBefore      = $cert.NotBefore
            NotAfter       = $cert.NotAfter
            DaysRemaining  = $daysLeft
            ExpirationStatus = if ($daysLeft -le 0) { "EXPIRED" } else { "WARNING" }
        }
        $results += $result
    }
}

# Sort by days remaining (soonest first)
$results = $results | Sort-Object DaysRemaining

# Output results
switch ($OutputFormat) {
    'Table' {
        $results | Format-Table -AutoSize -Property @(
            'Namespace',
            'SecretName',
            'DaysRemaining',
            'ExpirationStatus',
            'NotAfter',
            'Subject'
        )
    }
    'List' {
        foreach ($result in $results) {
            Write-Output "Namespace: $($result.Namespace)"
            Write-Output "Secret: $($result.SecretName)"
            Write-Output "Subject: $($result.Subject)"
            Write-Output "Issuer: $($result.Issuer)"
            Write-Output "Valid From: $($result.NotBefore)"
            Write-Output "Expires: $($result.NotAfter)"
            Write-Output "Days Remaining: $($result.DaysRemaining)"
            Write-Output "Status: $($result.ExpirationStatus)"
            Write-Output "----------------------------------------"
        }
    }
    'JSON' {
        $results | ConvertTo-Json -Depth 3
    }
}

# Exit with error code if expiring certificates found
if ($results.Count -gt 0) {
    exit 1
} else {
    Write-Output "No certificates found expiring within $DaysUntilExpiration days."
    exit 0
}
