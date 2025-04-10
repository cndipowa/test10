# Load JSON files
$users = Get-Content "users.json" | ConvertFrom-Json
$roles = Get-Content "roles.json" | ConvertFrom-Json
$privileges = Get-Content "privileges.json" | ConvertFrom-Json

# Convert role list to a hashtable for fast lookup
$roleMap = @{}
foreach ($role in $roles) {
    $roleMap[$role.id] = $role
}

# Convert privileges list to a hashtable for fast lookup
$privMap = @{}
foreach ($priv in $privileges) {
    $privMap[$priv.name] = $priv
}

# Flatten users and their associated roles and privileges
$results = foreach ($user in $users) {
    $userRoles = $user.roles + $user.externalRoles

    foreach ($roleId in $userRoles) {
        if ($roleMap.ContainsKey($roleId)) {
            $role = $roleMap[$roleId]
            $privs = $role.privileges

            if ($privs.Count -eq 0) {
                # No privileges assigned
                [PSCustomObject]@{
                    UserName   = $user.emailAddress
                    Role       = $roleId
                    Privilege  = ""
                    Actions    = ""
                    Repository = ""
                }
            } else {
                foreach ($privId in $privs) {
                    $priv = $privMap[$privId]
                    [PSCustomObject]@{
                        UserName   = $user.emailAddress
                        Role       = $roleId
                        Privilege  = $priv.name
                        Actions    = ($priv.actions -join ", ")
                        Repository = $priv.repository
                    }
                }
            }
        } else {
            # Role not found in role map
            [PSCustomObject]@{
                UserName   = $user.emailAddress
                Role       = $roleId
                Privilege  = "Role not found"
                Actions    = ""
                Repository = ""
            }
        }
    }
}

# Export to CSV
$results | Export-Csv -Path "nexus_user_roles_privileges.csv" -NoTypeInformation

Write-Host "Exported to nexus_user_roles_privileges.csv"
