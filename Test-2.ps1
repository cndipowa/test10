<#
.SYNOPSIS
    Get all OpenShift Routes and Kubernetes Ingresses with TLS configuration
.DESCRIPTION
    This script retrieves all Route and Ingress resources that have TLS configured
    across all namespaces in an OpenShift cluster and exports them to CSV files.
    The default cert is a wildcard.
.NOTES
    Requires: oc (OpenShift CLI) to be installed and authenticated
#>

$global:clusterUrl = oc whoami --show-server 2>$null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputFolder = "TLS_Config_Reports_$timestamp"

if (-not $clusterUrl) {
    Write-Error "Not logged into OpenShift or 'oc' command not found"
    exit 1
}

# Create output directory
New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null

# Function to get TLS Routes
function Get-TlsRoutes {
    Write-Host "`nTLS Routes:" -ForegroundColor Green
    [array]$routes = oc get routes --all-namespaces -o json | ConvertFrom-Json
    
    [array]$tlsRoutes = $routes.items | Where-Object { $_.spec.tls -ne $null }
    
    if ($tlsRoutes.Count -eq 0) {
        Write-Host "No TLS Routes found" -ForegroundColor Yellow
        return $null
    }

    $routeObjects = $tlsRoutes | ForEach-Object {
        [PSCustomObject]@{
            Namespace = $_.metadata.namespace
            Name = $_.metadata.name
            Host = $_.spec.host
            Termination = $_.spec.tls.termination
            Certificate = if ($_.spec.tls.certificate) { "Custom" } else { "Default" }
            InsecurePolicy = if ($_.spec.tls.insecureEdgeTerminationPolicy) { $_.spec.tls.insecureEdgeTerminationPolicy } else { "None" }
        }
    }

    $routeObjects | Format-Table -AutoSize
    Write-Host "Total TLS Routes count: " $tlsRoutes.Count -ForegroundColor Cyan

    # Export to CSV
    $csvPath = Join-Path -Path $outputFolder -ChildPath "TLS_Routes_$timestamp.csv"
    $routeObjects | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    Write-Host "TLS Routes exported to: $csvPath" -ForegroundColor Green

    return $routeObjects
}

# Function to get TLS Ingresses
function Get-TlsIngresses {
    Write-Host "`nTLS Ingresses:" -ForegroundColor Green
    [array]$ingresses = oc get ingress --all-namespaces -o json | ConvertFrom-Json
    
    [array]$tlsIngresses = $ingresses.items | Where-Object { $_.spec.tls -ne $null }
    
    if ($tlsIngresses.Count -eq 0) {
        Write-Host "No TLS Ingresses found" -ForegroundColor Yellow
        return $null
    }

    $ingressObjects = $tlsIngresses | ForEach-Object {
        [PSCustomObject]@{
            Namespace = $_.metadata.namespace
            Name = $_.metadata.name
            Hosts = ($_.spec.rules.host -join ", ")
            TLS_Hosts = ($_.spec.tls.hosts -join ", ")
            Secret = $_.spec.tls.secretName
        }
    }

    $ingressObjects | Format-Table -AutoSize
    Write-Host "Total TLS Ingress count: " $tlsIngresses.Count -ForegroundColor Cyan

    # Export to CSV
    $csvPath = Join-Path -Path $outputFolder -ChildPath "TLS_Ingresses_$timestamp.csv"
    $ingressObjects | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    Write-Host "TLS Ingresses exported to: $csvPath" -ForegroundColor Green

    return $ingressObjects
}

# Main execution
Write-Host "`nENVIRONMENT --> $clusterUrl" -ForegroundColor Cyan
Write-Host "`nCollecting TLS Routes and Ingresses..." -ForegroundColor Cyan

$routes = Get-TlsRoutes
$ingresses = Get-TlsIngresses

Write-Host "`nDone! ENVIRONMENT --> $clusterUrl" -ForegroundColor Green
Write-Host "Reports saved to folder: $outputFolder" -ForegroundColor Green
