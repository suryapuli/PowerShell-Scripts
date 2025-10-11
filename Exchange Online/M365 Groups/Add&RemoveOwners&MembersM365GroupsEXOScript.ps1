# Connect to Exchange Online
Connect-ExchangeOnline

# Load CSV
$users = Import-Csv -Path "C:\Scripts\ExchangeOnline\Add&RemoveOwners&MembersM365GroupsEXOTemplate\Add&RemoveOwners&MembersM365GroupsEXOTemplate.csv"

foreach ($user in $users) {
    $group = $user.M365GroupEmails
    $userEmail = $user.UserEmail
    $linkType = $user.LinkType
    $action = $user.Action.ToLower()

    try {
        if ($action -eq "add") {
            # Add user to group
            Add-UnifiedGroupLinks -Identity $group -LinkType $linkType -Links $userEmail
            Write-Host "Added $userEmail as $linkType to $group" -ForegroundColor Green
        }
        elseif ($action -eq "remove") {
            # Remove user from group
            Remove-UnifiedGroupLinks -Identity $group -LinkType $linkType -Links $userEmail -Confirm:$false
            Write-Host "Removed $userEmail as $linkType from $group" -ForegroundColor Yellow
        }
        else {
            Write-Warning "Unknown action '$action' for $userEmail in $group"
        }
    }
    catch {
        Write-Warning "Error processing $userEmail in $group as $linkType ($action): $_"
    }
}
