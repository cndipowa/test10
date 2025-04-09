# Path to JSON files
$usersFile = "users.json"
$rolesFile = "roles.json"
$privilegesFile = "privileges.json"
$outputCsv = "nexus_users_report.csv"

# Load JSON content
$users = Get-Content $usersFile | ConvertFrom-Json
$roles = Get-Content $rolesFile | ConvertFrom-Json
$privileges = Get-Content $privilegesFile | ConvertFrom-Json

# Convert roles and privileges into hashtables for easy lookup
$roleMap = @{}
foreach ($role in $roles) {
    $roleMap[$role.id] = $role
}

$privilegeMap = @{}
foreach ($priv in $privileges) {
    $privilegeMap[$priv.id] = $priv
}

# Expand roles recursively to get all privileges (in case of nested roles)
function Get-PrivilegesFromRoles($roleIds, $visitedRoles = @{}) {
    $allPrivileges = @()

    foreach ($roleId in $roleIds) {
        if ($visitedRoles.Contains($roleId)) { continue }
        $visitedRoles += $roleId

        $role = $roleMap[$roleId]
        if (-not $role) { continue }

        $allPrivileges += $role.privileges

        if ($role.roles) {
            $nestedPrivileges = Get-PrivilegesFromRoles -roleIds $role.roles -visitedRoles $visitedRoles
            $allPrivileges += $nestedPrivileges
        }
    }

    return $allPrivileges | Sort-Object -Unique
}

# Prepare data to export
$userReport = @()
foreach ($user in $users) {
    $userRoles = $user.roles
    $privileges = Get-PrivilegesFromRoles -roleIds $userRoles

    $privDetails = $privileges | ForEach-Object { 
        if ($privilegeMap.ContainsKey($_)) {
            $privilegeMap[$_].name
        } else {
            $_
        }
    }

    $userReport += [PSCustomObject]@{
        Username    = $user.userId
        Roles       = ($userRoles -join ", ")
        Privileges  = ($privDetails -join ", ")
    }
}

# Export to CSV
$userReport | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8

# Display in console
$userReport | Format-Table -AutoSize

