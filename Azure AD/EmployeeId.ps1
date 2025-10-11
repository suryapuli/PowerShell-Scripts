# Connect to Azure AD
Connect-AzureAD

# Import the CSV
$users = Import-Csv -Path "C:\Scripts\Template.csv" # Change the path

# Loop through each user and update the employeeId
foreach ($user in $users) {
    try {
        Set-AzureADUserExtension -ObjectId $user.UserPrincipalName `
                                 -ExtensionName "employeeId" `
                                 -ExtensionValue $user.EmployeeId
        Write-Host "Updated employeeId for $($user.UserPrincipalName)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to update $($user.UserPrincipalName): $_" -ForegroundColor Red
    }
}
