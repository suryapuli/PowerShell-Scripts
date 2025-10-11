# Connect to Microsoft Graph
Connect-MgGraph -Scopes "GroupMember.ReadWrite.All", "User.Read.All"

# Use your known Group ID
$groupId = "XXXXXXXXXXXXXXXXXXXXXXXXXXX" # replace with actual group object ID

# Import UPNs from CSV
$userList = Import-Csv -Path "C:\Scripts\Intune\Users\AddUsersToSecurityGroupMembers.csv"

foreach ($entry in $userList) {
    $upn = $entry.UserPricipalName
    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    
    if ($user) {
        try {
            New-MgGroupMember -GroupId $groupId -DirectoryObjectId $user.Id
            Write-Host " Added $upn to group."
        } catch {
            Write-Host " Error adding $upn: $_"
        }
    } else {
        Write-Host " User not found: $upn"
    }
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph