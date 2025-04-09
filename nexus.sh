<#
.SYNOPSIS
    Retrieves all users, their roles, and associated privileges from Nexus Repository Manager.
.DESCRIPTION
    This script connects to a Nexus Repository Manager instance via REST API and extracts:
    - All users
    - Their assigned roles
    - Privileges associated with those roles
    Output is formatted for easy review.
.NOTES
    File Name      : Get-NexusUserRoles.ps1
    Prerequisites  : PowerShell 5.1 or later
                    Access to Nexus REST API (admin credentials)
                    Nexus Repository Manager 3.x
#>

# Configuration
$NexusUrl = "http://your-nexus-server:8081"  # Change to your Nexus URL
$Credential = Get-Credential -Message "Enter Nexus admin credentials"

# Headers for API requests
$headers = @{
    "Accept" = "application/json"
    "Content-Type" = "application/json"
}

# Function to handle API requests
function Invoke-NexusRequest {
    param (
        [string]$Uri,
        [string]$Method = "GET"
    )
    
    try {
        $response = Invoke-RestMethod -Uri "$NexusUrl/service/rest/$Uri" -Method $Method `
            -Headers $headers -Credential $Credential -SkipCertificateCheck
        return $response
    }
    catch {
        Write-Warning "Error accessing $Uri : $($_.Exception.Message)"
        return $null
    }
}

# Get all users
Write-Host "Retrieving all users..."
$users = Invoke-NexusRequest -Uri "v1/security/users"

# Get all roles
Write-Host "Retrieving all roles..."
$roles = Invoke-NexusRequest -Uri "v1/security/roles"

# Get all privileges
Write-Host "Retrieving all privileges..."
$privileges = Invoke-NexusRequest -Uri "v1/security/privileges"

# Create a hashtable for quick privilege lookup
$privilegeLookup = @{}
foreach ($priv in $privileges) {
    $privilegeLookup[$priv.id] = $priv
}

# Process each user and their roles
$output = @()
foreach ($user in $users) {
    $userRoles = @()
    $userPrivileges = @()
    
    foreach ($roleId in $user.roles) {
        $role = $roles | Where-Object { $_.id -eq $roleId }
        if ($role) {
            $userRoles += $role.name
            
            # Get privileges for this role
            foreach ($privId in $role.privileges) {
                if ($privilegeLookup.ContainsKey($privId)) {
                    $userPrivileges += $privilegeLookup[$privId].name
                }
            }
        }
    }
    
    # Create output object
    $output += [PSCustomObject]@{
        UserId       = $user.userId
        FirstName    = $user.firstName
        LastName     = $user.lastName
        Email        = $user.emailAddress
        Status      = $user.status
        Roles       = ($userRoles -join ", ")
        Privileges  = ($userPrivileges | Sort-Object -Unique) -join ", "
    }
}

# Display results
$output | Format-Table -AutoSize

# Optionally export to CSV
$exportPath = "NexusUserPermissions_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$output | Export-Csv -Path $exportPath -NoTypeInformation
Write-Host "Results exported to $exportPath"


#!/bin/bash

# Nexus API URL
NEXUS_URL="http://localhost:8081/service/rest"
USER="admin"
PASS="your_admin_password"  # Replace with actual password or fetch from mounted file

echo "Fetching all users..."

users=$(curl -s -u $USER:$PASS "$NEXUS_URL/beta/security/users" | jq -r '.[].userId')

for user in $users; do
  echo "-----------------------------"
  echo "User: $user"

  # Get user details (includes roles)
  user_info=$(curl -s -u $USER:$PASS "$NEXUS_URL/beta/security/users/$user")
  roles=$(echo "$user_info" | jq -r '.roles[]')

  echo "Roles:"
  for role in $roles; do
    echo "  - $role"

    # Get role details to show privileges
    role_info=$(curl -s -u $USER:$PASS "$NEXUS_URL/beta/security/roles/$role")
    privileges=$(echo "$role_info" | jq -r '.privileges[]?')

    if [ -n "$privileges" ]; then
      echo "    Privileges:"
      for priv in $privileges; do
        echo "      * $priv"
      done
    else
      echo "    (No privileges found)"
    fi
  done
done
