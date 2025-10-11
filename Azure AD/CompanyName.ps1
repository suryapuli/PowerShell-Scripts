Connect-AzureAD

$users = Import-Csv "C:\Scripts\Template.csv" #change it
 
foreach ($user in $users)
{
Set-AzureADUser -ObjectID $user.UserPrincipalName`
-CompanyName $user.CompanyName `
}