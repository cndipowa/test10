<#
.SYNOPSIS
    Get all OpenShift Routes and Kubernetes Ingresses with TLS configuration
.DESCRIPTION
    This script retrieves all Route and Ingress resources that have TLS configured
    across all namespaces in an OpenShift cluster.
    The default cert is a wildcard.
.NOTES
    Requires: oc (OpenShift CLI) to be installed and authenticated
#>


$global:clusterUrl = oc whoami --show-server 2>$null

if (-not $clusterUrl) {
    Write-Error "Not logged into OpenShift or 'oc' command not found"
    exit 1
}


# Function to get TLS Routes
function Get-TlsRoutes {
    Write-Host "`nTLS Routes:" -ForegroundColor Green
    [array]$routes = oc get routes --all-namespaces -o json | ConvertFrom-Json
    
    [array]$tlsRoutes = $routes.items | Where-Object { $_.spec.tls -ne $null }
    
    if ($tlsRoutes.Count -eq 0) {
        Write-Host "No TLS Routes found" -ForegroundColor Yellow
        return
    }

    $tlsRoutes | ForEach-Object {
        [PSCustomObject]@{
            Namespace = $_.metadata.namespace
            Name = $_.metadata.name
            Host = $_.spec.host
            Termination = $_.spec.tls.termination
            Certificate = if ($_.spec.tls.certificate) { "Custom" } else { "Default" }
        }
    } | Format-Table -AutoSize

    Write-Host "Total TLS Routes count: " $tlsRoutes.Count -ForegroundColor Cyan
}

# Function to get TLS Ingresses
function Get-TlsIngresses {
    Write-Host "`nTLS Ingresses:" -ForegroundColor Green
    [array]$ingresses = oc get ingress --all-namespaces -o json | ConvertFrom-Json
    
    [array]$tlsIngresses = $ingresses.items | Where-Object { $_.spec.tls -ne $null }
    
    if ($tlsIngresses.Count -eq 0) {
        Write-Host "No TLS Ingresses found" -ForegroundColor Yellow
        return
    }

    $tlsIngresses | ForEach-Object {
        [PSCustomObject]@{
            Namespace = $_.metadata.namespace
            Name = $_.metadata.name
            Hosts = ($_.spec.rules.host -join ", ")
            TLS_Hosts = ($_.spec.tls.hosts -join ", ")
            Secret = $_.spec.tls.secretName
        }
    } | Format-Table -AutoSize

    Write-Host "Total TLS Ingress count: " $tlsIngresses.Count -ForegroundColor Cyan
}

# Main execution

Write-Host "`nENVIRONMENT --> " $clusterUrl -ForegroundColor Cyan
Write-Host "`nCollecting TLS Routes and Ingresses..." -ForegroundColor Cyan

Get-TlsRoutes
Get-TlsIngresses

Write-Host "`nDone! ENVIRONMENT --> " $clusterUrl  -ForegroundColor green
