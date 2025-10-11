Connect-ExchangeOnline

$csvPath = "C:\Scripts\ExchangeOnline\Distribution Lists\DistributionListTemplate.csv"
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
    switch ("$($user.Action)-$($user.PermissionType)") {
        "Add-Member" {
            Add-DistributionGroupMember -Identity $user.DistributionGroupID -Member $user.UserPrincipalName
            Write-Host "Added Member $($user.UserPrincipalName) to DL $($user.DistributionGroupID)"
        }
        "Remove-Member" {
            Remove-DistributionGroupMember -Identity $user.DistributionGroupID -Member $user.UserPrincipalName -Confirm:$false
            Write-Host "Removed Member $($user.UserPrincipalName) from DL $($user.DistributionGroupID)"
        }
        "Add-Owner" {
            Set-DistributionGroup -Identity $user.DistributionGroupID -ManagedBy @{Add=$user.UserPrincipalName} -BypassSecurityGroupManagerCheck
            Write-Host "Added Owner $($user.UserPrincipalName) to DL $($user.DistributionGroupID)"
        }
        "Remove-Owner" {
            Set-DistributionGroup -Identity $user.DistributionGroupID -ManagedBy @{Remove=$user.UserPrincipalName} -BypassSecurityGroupManagerCheck
            Write-Host "Removed Owner $($user.UserPrincipalName) from DL $($user.DistributionGroupID)"
        }
        default {
            Write-Warning "Unknown action '$($user.Action)' or permission type '$($user.PermissionType)' for $($user.UserPrincipalName)"
        }
    }
}
