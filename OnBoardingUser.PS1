# Authenticate Services
Connect-ExchangeOnline -UserPrincipalName firstname.lastname@domain.com
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "Policy.ReadWrite.AuthenticationMethod"

# Define groups here to add members
$bangaloreGroup = Get-MgGroup -Filter "displayName eq 'GroupName'" -ConsistencyLevel eventual    # replace GroupName with actual name
$hyderabadGroup = Get-MgGroup -Filter "displayName eq 'GroupName'" -ConsistencyLevel eventual    # replace GroupName with actual name
# Add more as above if you want

# Define groups here for group based licensing
$licenseO365E1Group = Get-MgGroup -Filter "displayName eq 'GroupName'" -ConsistencyLevel eventual   # replace GroupName with actual name
$licenseM365E3Group = Get-MgGroup -Filter "displayName eq 'GroupName'" -ConsistencyLevel eventual   # replace GroupName with actual name

# Import user data from CSV file
$users = Import-Csv -Path "C:\Scripts\OnBoardingUserCreation\OnBoardingUserTemplate.csv"   # replace with actual path

foreach ($user in $users) {
    try {
        $log = @()
        $log += "`n==============================="
        $log += " $($user.DisplayName)  |  $($user.UserPrincipalName)"
        $log += " Department: $($user.Department)  |  Location: $($user.City), $($user.Country)"

# Skip if user already exists
        $existingUser = Get-MgUser -Filter "userPrincipalName eq '$($user.UserPrincipalName)'" -ErrorAction SilentlyContinue
        if ($existingUser) {
            $log += " User already exists. Skipping creation."
            $log | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
        }
        
# Create User
        $newUser = New-MgUser -AccountEnabled:$true `
            -DisplayName $user.DisplayName `
            -UserPrincipalName $user.UserPrincipalName `
            -MailNickname $user.MailNickname `
            -GivenName $user.FirstName `
            -Surname $user.LastName `
            -JobTitle $user.JobTitle `
            -Department $user.Department `
            -CompanyName $user.CompanyName `
            -EmployeeId $user.EmployeeId `
            -EmployeeType $user.EmployeeType `
            -OfficeLocation $user.OfficeLocation `
            -StreetAddress $user.StreetAddress `
            -City $user.City `
            -State $user.State `
            -PostalCode $user.PostalCode `
            -Country $user.Country `
            -BusinessPhones @($user.BusinessPhone) `
            -MobilePhone $user.MobilePhone `
            -Mail $user.Mail `
            -OtherMails @($user.OtherMails) `
            -UsageLocation $user.UsageLocation `
            -PasswordProfile @{ 
                ForceChangePasswordNextSignIn = $true
                Password = $user.Password 
            }

        # Assign users to security group for licensing
        if ($user.LicenseType -eq "SPE_E3") {
            if ($licenseM365E3Group) {
  New-MgGroupMember -GroupId $licenseM365E3Group.Id -DirectoryObjectId $newUser.Id
            $log += " Added to GroupName group for license provisioning"            # Replace GroupName with actual name
        } else {
            $log += " GroupName group not found — license assignment skipped"       # Replace GroupName with actual name
        }
        }
        if ($user.LicenseType -eq "STANDARDPACK") {
            if ($licenseO365E1Group) {
  New-MgGroupMember -GroupId $licenseO365E1Group.Id -DirectoryObjectId $newUser.Id
            $log += " Added to GroupName group for license provisioning"            # Replace GroupName with actual name
        } else {
            $log += " GroupName group not found — license assignment skipped"       # Replace GroupName with actual name
        }
        }

        # Assign manager to user
        if ($user.ManagerUPN) {
            $manager = Get-MgUser -UserId $user.ManagerUPN
            if ($manager) {
                Set-MgUserManagerByRef -UserId $newUser.Id -BodyParameter @{
                    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($manager.Id)"
                }
                $log += " Manager assigned: $($user.ManagerUPN)"
            } else {
                $log += " Manager '$($user.ManagerUPN)' not found"
            }
        }

        # Users will add into the M365 groups based on CITY
        if ($user.Country -eq "India") {
            $mgUser = Get-MgUser -UserId $user.UserPrincipalName
            if ($mgUser) {
                if ($user.City -eq "Bangalore" -and $bangaloreGroup) {
                    New-MgGroupMember -GroupId $bangaloreGroup.Id -DirectoryObjectId $mgUser.Id
                    $log += " Added to Bangalore group"
                } elseif ($user.City -eq "Hyderabad" -and $hyderabadGroup) {
                    New-MgGroupMember -GroupId $hyderabadGroup.Id -DirectoryObjectId $mgUser.Id
                    $log += " Added to Hyderabad group"
                } else {
                    $log += " No group matched for city '$($user.City)'"
                }
            }
        }

        
        # Enable or manage Per-User MFA
        $desiredMfaState = $user.EnableMFA.ToUpper()
        switch ($desiredMfaState) {
            "ENABLED" { $mfaState = "enabled" }
            "ENFORCED" { $mfaState = "enforced" }
            "DISABLED" { $mfaState = "disabled" }
             Default {
                $log += " Invalid MFA state '$($user.EnableMFA)'"
                $mfaState = $null
            }
        }

        if ($mfaState) {
            $uri = "/beta/users/$($newUser.Id)/authentication/requirements"
            $body = @{ perUserMfaState = $mfaState } | ConvertTo-Json
            Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType "application/json"
            $log += " MFA state '$mfaState' applied"
        }

# Enable Litigation Hold for Exchange Online Plan 2 Users
if ($user.LicenseType -in @("SPE_E3", "ENTERPRISEPACK")) {
    $mailboxProvisioned = $false
    $maxRetries = 6
    $retryCount = 0

    do {
        Start-Sleep -Seconds 10
        try {
            $mailbox = Get-Mailbox -Identity $user.UserPrincipalName -ErrorAction Stop
            $mailboxProvisioned = $true
            $log += " Mailbox provisioning confirmed (Attempt $retryCount)"
        } catch {
            $log += " Waiting for mailbox to provision (Attempt $retryCount of $maxRetries)"
        }
        $retryCount++
    } while (-not $mailboxProvisioned -and $retryCount -lt $maxRetries)

    if ($mailboxProvisioned) {
        try {
            Set-Mailbox -Identity $user.UserPrincipalName -LitigationHoldEnabled $true
            $log += " Litigation Hold enabled "
        } catch {
            $log += " Failed to enable Litigation Hold "
        }
    } else {
        $log += " Skipped Litigation Hold — mailbox not provisioned after $maxRetries retries "
    }
} else {
    $log += " Skipped Litigation Hold — LicenseType is '$($user.LicenseType)'"
}

        $log += " Onboarding complete."
        $log += "==============================="

        $log | ForEach-Object { Write-Host $_ -ForegroundColor White }

    } catch {
        Write-Error " Failed to onboard $($user.DisplayName): $_"
    }
}
