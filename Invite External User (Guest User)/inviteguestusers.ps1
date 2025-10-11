#Install the Microsoft Graph PowerShell module if not already installed
#prerequisit module before running the scripts
#Install-Module -Name Microsoft.Graph -Scope AllUser

# Connect to Microsoft Graph
Connect-MgGraph -Scopes 'User.ReadWrite.All'

# company read from excel

# Import the CSV file
$guestUsers = Import-Excel -Path "C:\Scripts\GuestUsersInvitation\guestusers.xlsx" -WorksheetName 'GuestUsers'

foreach ($user in $guestUsers) {
$sponsor=Get-MgUser -UserId $user.Requester
$sponsorParams = @{
    Id = $sponsor.Id;    
}
$sponsors = @($sponsorParams)
$invitedMessage = @{CustomizedMessageBody = "Welcome to collaborate with (CompanyName)! We just added your account as a guest user account in (CompanyName) Azure AD Tenant!"}

# Define guest user details

$invitationParams = @{
    InvitedUserDisplayName = $user.DisplayName
    InvitedUserEmailAddress = $user.Email
    InviteRedirectUrl = "(EnterCompanyURL)"
    InvitedUserMessageInfo = $invitedMessage
    SendInvitationMessage = $true
    InvitedUserSponsors = $sponsors
}

$invitation = New-MgInvitation -BodyParameter $invitationParams

Update-MgUser -UserId $invitation.InvitedUser.Id -GivenName $user.FirstName -Surname $user.LastName -CompanyName $user.Company
}


