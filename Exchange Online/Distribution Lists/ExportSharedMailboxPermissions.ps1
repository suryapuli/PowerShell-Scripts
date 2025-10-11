# Ensure ImportExcel module is installed
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Install-Module -Name ImportExcel -Scope CurrentUser -Force
}

# Connect to Exchange Online
Connect-ExchangeOnline

# Define the shared mailbox you want to check
$mailboxEmail = "sharedmailbox@domain.com"  # Replace with actual mailbox address

# Get mailbox object
$mailbox = Get-Mailbox -Identity $mailboxEmail

# Create an empty array to store results
$results = @()

# Get Full Access permissions
$fullAccess = Get-MailboxPermission -Identity $mailboxEmail |
    Where-Object { ($_.User -like "*@*") -and ($_.AccessRights -contains "FullAccess") }

foreach ($entry in $fullAccess) {
    $results += [PSCustomObject]@{
        Mailbox         = $mailbox.DisplayName
        Email           = $mailboxEmail
        PermissionType  = "Full Access"
        User            = $entry.User
    }
}

# Get Send As permissions
$sendAs = Get-RecipientPermission -Identity $mailboxEmail |
    Where-Object { $_.AccessRights -contains "SendAs" }

foreach ($entry in $sendAs) {
    $results += [PSCustomObject]@{
        Mailbox         = $mailbox.DisplayName
        Email           = $mailboxEmail
        PermissionType  = "Send As"
        User            = $entry.Trustee
    }
}

# Get Send on Behalf permissions
$sendOnBehalf = $mailbox.GrantSendOnBehalfTo
foreach ($user in $sendOnBehalf) {
    $results += [PSCustomObject]@{
        Mailbox         = $mailbox.DisplayName
        Email           = $mailboxEmail
        PermissionType  = "Send on Behalf"
        User            = $user.Name
    }
}

# Export results to Excel
$excelPath = "C:\Scripts\ExportPermissions for SharedMailbox&DL.xlsx" # Create a excel sheet
$results | Export-Excel -Path $excelPath -AutoSize -WorksheetName "$mailboxEmail" -Show
