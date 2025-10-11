Connect-ExchangeOnline

$users = Import-Csv "C:\Scripts\Template.csv"
foreach ($user in $users) 
{
    $userPrincipalName = $user.userPrincipalName
    $manager = $user.ManagerUPN
    Set-User -Identity $userPrincipalName -Manager $manager
    Write-Host "Updated Reporting Manager for $userPrincipalName to $manager" -ForegroundColor Yellow
}