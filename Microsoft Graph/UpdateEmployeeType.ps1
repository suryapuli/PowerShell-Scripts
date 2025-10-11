# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Import the CSV
$users = Import-Csv -Path "C:\Scripts\Template.csv"

# Loop through each user and update employeeType
foreach ($user in $users) {
    $upn = $user.UserPrincipalName
    $etype = $user.EmployeeType

    Write-Host "Updating employeeType for $upn to $etype" -ForegroundColor Yellow

    Update-MgUser -UserId $upn -EmployeeType $etype

    Write-Host "Successfully updated $upn" -ForegroundColor Green
}
