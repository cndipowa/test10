# Define LDAP connection details
$ldapServer = "ldap.forumsys.com"
$ldapPort = 636
$bindDN = "cn=read-only-admin,dc=example,dc=com"
$password = "password"

# Create LDAP connection
$identifier = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($ldapServer, $ldapPort, $false, $false)
$credential = New-Object System.Net.NetworkCredential($bindDN, $password)
$connection = New-Object System.DirectoryServices.Protocols.LdapConnection($identifier, $credential, [System.DirectoryServices.Protocols.AuthType]::Basic)

# Enable SSL
$connection.SessionOptions.SecureSocketLayer = $true
$connection.SessionOptions.VerifyServerCertificate = { $true }

# Optional timeout
$connection.Timeout = New-TimeSpan -Seconds 10

# Bind
$connection.Bind()

# Perform search
$searchBase = "dc=example,dc=com"
$searchFilter = "(objectClass=*)"
$searchScope = [System.DirectoryServices.Protocols.SearchScope]::Subtree
$searchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest($searchBase, $searchFilter, $searchScope, $null)
$searchResponse = $connection.SendRequest($searchRequest)

# Display results
foreach ($entry in $searchResponse.Entries) {
    Write-Host "DN: $($entry.DistinguishedName)"
    foreach ($attrName in $entry.Attributes.AttributeNames) {
        $values = $entry.Attributes[$attrName]
        Write-Host " - $attrName: $values"
    }
}
