Connect-AzureAD

Import-Csv "C:\Scripts\Template.csv" | ForEach-Object { # Change the path
$upn = $_."UserPrincipalName"
$title = $_."JobTitle"
Write-Host "Changing destignation value of: "$upn" to: " $title -ForegroundColor Yellow
Set-AzureADUser -ObjectId $upn  -JobTitle $title
}