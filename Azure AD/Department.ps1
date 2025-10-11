Connect-AzureAD

Import-Csv "C:\Scripts\Template.csv" | ForEach-Object { # change the path
$upn = $_."UserPrincipalName"
$Department = $_."Department"
Write-Host "Changing destignation value of: "$upn" to: " $Department -ForegroundColor Yellow
Set-AzureADUser -ObjectId $upn  -Department $Department
}