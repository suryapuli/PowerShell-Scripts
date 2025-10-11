Connect-ExchangeOnline

$csvPath = "C:\Scripts\ExchangeOnline\Shared Mailbox\SharedMailboxTemplate.csv"
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
    switch ("$($user.Action)-$($user.PermissionType)") {
        "Add-FullAccess" {
            Add-MailboxPermission -Identity $user.SharedMailboxID -User $user.UserPrincipalName -AccessRights FullAccess -InheritanceType All -Confirm:$false
            Write-Host "Granted Full Access to $($user.UserPrincipalName) for $($user.SharedMailboxID)"
        }
        "Remove-FullAccess" {
            Remove-MailboxPermission -Identity $user.SharedMailboxID -User $user.UserPrincipalName -AccessRights FullAccess -InheritanceType All -Confirm:$false
            Write-Host "Removed Full Access from $($user.UserPrincipalName) for $($user.SharedMailboxID)"
        }
        "Add-SendAs" {
            Add-RecipientPermission -Identity $user.SharedMailboxID -Trustee $user.UserPrincipalName -AccessRights SendAs -Confirm:$false
            Write-Host "Granted Send As to $($user.UserPrincipalName) for $($user.SharedMailboxID)"
        }
        "Remove-SendAs" {
            Remove-RecipientPermission -Identity $user.SharedMailboxID -Trustee $user.UserPrincipalName -AccessRights SendAs -Confirm:$false
            Write-Host "Removed Send As from $($user.UserPrincipalName) for $($user.SharedMailboxID)"
        }
        "Add-SendOnBehalf" {
            Set-Mailbox -Identity $user.SharedMailboxID -GrantSendOnBehalfTo @{Add=$user.UserPrincipalName}
            Write-Host "Granted Send on Behalf to $($user.UserPrincipalName) for $($user.SharedMailboxID)"
        }
        "Remove-SendOnBehalf" {
            Set-Mailbox -Identity $user.SharedMailboxID -GrantSendOnBehalfTo @{Remove=$user.UserPrincipalName}
            Write-Host "Removed Send on Behalf from $($user.UserPrincipalName) for $($user.SharedMailboxID)"
        }
         default {
            Write-Warning "Unknown action '$($user.Action)' or permission type '$($user.PermissionType)' for $($user.UserPrincipalName)"
        }
    }
}
