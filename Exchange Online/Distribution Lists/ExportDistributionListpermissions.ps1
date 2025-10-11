# Ensure ImportExcel module is installed
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Install-Module -Name ImportExcel -Scope CurrentUser -Force
}

# Connect to Exchange Online
Connect-ExchangeOnline

# Define the DL you want to audit
$dlIdentity = "distributionlist@domain.com"  # Replace with your DL email or name

# Get DL object
$dl = Get-DistributionGroup -Identity $dlIdentity

# Create an empty array to store results
$results = @()

# Get DL Members
$members = Get-DistributionGroupMember -Identity $dlIdentity
foreach ($member in $members) {
    $results += [PSCustomObject]@{
        DL              = $dl.DisplayName
        Email           = $dl.PrimarySmtpAddress
        Role            = "Member"
        User            = $member.PrimarySmtpAddress
    }
}

# Get DL Owners (ManagedBy)
$owners = $dl.ManagedBy
foreach ($owner in $owners) {
    $results += [PSCustomObject]@{
        DL              = $dl.DisplayName
        Email           = $dl.PrimarySmtpAddress
        Role            = "Owner"
        User            = $owner.PrimarySmtpAddress
    }
}

# Export results to Excel
$excelPath = "C:\Scripts\ExportPermissions for SharedMailbox&DL.xlsx" # create a empty excel sheet
$results | Export-Excel -Path $excelPath -AutoSize -WorksheetName "$dlIdentity" -Show
