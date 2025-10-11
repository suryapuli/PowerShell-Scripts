Connect-MGGraph
$users = Import-Csv "C:\Scripts\Template.csv"

foreach ($user in $users) {
    Write-Host "Updating user: $($user.UserPrincipalName)..."

    try {
        Update-MgUser -UserId $user.UserPrincipalName `
            -StreetAddress $user.StreetAddress `
            -City $user.City `
            -State $user.State `
            -PostalCode $user.PostalCode `
            -Country $user.Country `
            -BusinessPhones @($user.BusinessPhone) `
            -OfficeLocation $user.OfficeLocation

        Write-Host " Successfully updated: $($user.UserPrincipalName)`n"
    } catch {
        Write-Error " Failed to update $($user.UserPrincipalName): $_"
    }
}
