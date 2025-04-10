# Load JSON files
$users = Get-Content "users.json" | ConvertFrom-Json
$roles = Get-Content "roles.json" | ConvertFrom-Json
$privileges = Get-Content "privileges.json" | ConvertFrom-Json

# Convert to hash maps for fast lookup
$roleMap = @{}
foreach ($role in $roles) {
    $roleMap[$role.id] = $role
}

$privMap = @{}
foreach ($priv in $privileges) {
    $privMap[$priv.name] = $priv
}

# Recursive role traversal to collect all privileges for a role
function Get-AllPrivilegesFromRole {
    param (
        [string]$roleId,
        [hashtable]$visitedRoles
    )

    $results = @()

    if ($visitedRoles.ContainsKey($roleId)) {
        return $results  # Prevent circular recursion
    }

    $visitedRoles[$roleId] = $true

    if ($roleMap.ContainsKey($roleId)) {
        $role = $roleMap[$roleId]

        # Direct privileges
        foreach ($privId in $role.privileges) {
            if ($privMap.ContainsKey($privId)) {
                $results += [PSCustomObject]@{
                    Role       = $roleId
                    Privilege  = $privId
                    Actions    = ($privMap[$privId].actions -join ", ")
                    Repository = $privMap[$privId].repository
                }
            }
        }

        # Recursively get privileges from nested roles
        foreach ($nestedRoleId in $role.roles) {
            $results += Get-AllPrivilegesFromRole -roleId $nestedRoleId -visitedRoles $visitedRoles
        }
    } else {
        $results += [PSCustomObject]@{
            Role       = $roleId
            Privilege  = "Role not found"
            Actions    = ""
            Repository = ""
        }
    }

    return $results
}

# Gather all users and their resolved privileges
$results = foreach ($user in $users) {
    $userRoles = $user.roles + $user.externalRoles
    foreach ($roleId in $userRoles) {
        $visited = @{}
        $resolvedPrivs = Get-AllPrivilegesFromRole -roleId $roleId -visitedRoles $visited

        if ($resolvedPrivs.Count -eq 0) {
            [PSCustomObject]@{
                UserName   = $user.emailAddress
                Role       = $roleId
                Privilege  = ""
                Actions    = ""
                Repository = ""
            }
        } else {
            foreach ($priv in $resolvedPrivs) {
                [PSCustomObject]@{
                    UserName   = $user.emailAddress
                    Role       = $priv.Role
                    Privilege  = $priv.Privilege
                    Actions    = $priv.Actions
                    Repository = $priv.Repository
                }
            }
        }
    }
}

# Export to CSV
$results | Export-Csv -Path "nexus_user_roles_privileges.csv" -NoTypeInformation
Write-Host "✅ Exported to nexus_user_roles_privileges.csv"
