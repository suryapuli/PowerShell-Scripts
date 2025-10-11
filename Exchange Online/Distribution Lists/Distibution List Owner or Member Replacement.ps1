Connect-ExchangeOnline

$csvPath = "C:\Scripts\ExchangeOnline\Distribution Lists\DistributionListReplacementTemplate.csv"
$entries = Import-Csv -Path $csvPath

# Group entries by DL and PermissionType for replacement
$grouped = $entries | Where-Object { $_.Action -eq "Replace" } |
    Group-Object -Property DistributionGroupID, PermissionType

foreach ($group in $grouped) {
    $dl = $group.Group[0].DistributionGroupID
    $type = $group.Group[0].PermissionType
    $users = $group.Group | Select-Object -ExpandProperty UserPrincipalName

    switch ($type) {
        "Member" {
            Update-DistributionGroupMember -Identity $dl -Members $users -Confirm:$false
            Write-Host "Replaced all members in DL $dl with: $($users -join ', ')"
        }
        "Owner" {
            Set-DistributionGroup -Identity $dl -ManagedBy $users -BypassSecurityGroupManagerCheck
            Write-Host "Replaced all owners in DL $dl with: $($users -join ', ')"
        }
        default {
            Write-Warning "Unknown permission type '$type' for DL $dl"
        }
    }
}
