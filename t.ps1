<#
.SYNOPSIS
    Generates a report of Nexus users with their roles and associated privileges.
.DESCRIPTION
    This script reads users.json, roles.json, and privileges.json files to create a comprehensive
    report showing all users, their assigned roles, and the privileges associated with those roles.
    The output is displayed on screen and exported to a CSV file.
.NOTES
    File Name      : NexusUserRoleReport.ps1
    Prerequisite  : PowerShell 5.1 or later
    Input Files   : users.json, roles.json, privileges.json in the same directory as the script
#>

# Initialize variables
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputFile = Join-Path $scriptPath "Nexus_Users_Roles_Privileges_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

# Load JSON files
try {
    $users = Get-Content (Join-Path $scriptPath "users.json") -Raw | ConvertFrom-Json
    $roles = Get-Content (Join-Path $scriptPath "roles.json") -Raw | ConvertFrom-Json
    $privileges = Get-Content (Join-Path $scriptPath "privileges.json") -Raw | ConvertFrom-Json
}
catch {
    Write-Error "Failed to load JSON files: $_"
    exit 1
}

# Create a hashtable for quick privilege lookup by ID
$privilegeLookup = @{}
$privileges | ForEach-Object {
    $privilegeLookup[$_.id] = $_.name
}

# Create a hashtable for roles with expanded privileges
$roleDetails = @{}
$roles | ForEach-Object {
    $role = $_
    $privilegeNames = $role.privileges | ForEach-Object {
        if ($privilegeLookup.ContainsKey($_)) {
            $privilegeLookup[$_]
        }
        else {
            $_
        }
    }
    
    $roleDetails[$role.id] = @{
        Name = $role.name
        Description = $role.description
        Privileges = $privilegeNames -join ", "
    }
}

# Process users and their roles
$report = @()

foreach ($user in $users) {
    $userRoles = $user.roles | ForEach-Object {
        if ($roleDetails.ContainsKey($_)) {
            $roleDetails[$_].Name
        }
        else {
            $_
        }
    }
    
    $userPrivileges = $user.roles | ForEach-Object {
        if ($roleDetails.ContainsKey($_)) {
            $roleDetails[$_].Privileges
        }
    } | Sort-Object -Unique
    
    # Clean up privileges list (remove duplicates from multiple roles)
    $uniquePrivileges = ($userPrivileges -split ", " | Sort-Object -Unique) -join ", "
    
    $report += [PSCustomObject]@{
        UserId = $user.userId
        FirstName = $user.firstName
        LastName = $user.lastName
        Email = $user.emailAddress
        Status = $user.status
        Roles = $userRoles -join ", "
        Privileges = $uniquePrivileges
    }
}

# Display report on screen
$report | Format-Table -AutoSize

# Export to CSV
try {
    $report | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
    Write-Host "Report successfully exported to: $outputFile" -ForegroundColor Green
}
catch {
    Write-Error "Failed to export CSV: $_"
}

# Display completion message
Write-Host "`nProcessing complete. Found $($report.Count) users with their associated roles and privileges."
