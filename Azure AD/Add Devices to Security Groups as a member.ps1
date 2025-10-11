# Connect to Azure AD
Connect-AzureAD

# Define the path to your CSV file
$csvPath = "C:\Scripts\Intune\Devices\AddDevicesToSecurityGroupMembers.csv"

# Define the target Security Group ID 
$groupId = "XXXXXXXXXXXXXXXXXXXXXXX"   # replace with actual group object ID

# Import the CSV
$devices = Import-Csv -Path $csvPath

foreach ($device in $devices) {
    $deviceName = $device.DeviceName

    # Get the device object from Azure AD
    $deviceObj = Get-AzureADDevice -SearchString $deviceName

    if ($deviceObj) {
        # Add the device to the group
        Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $deviceObj.ObjectId
        Write-Host "Added $deviceName to group."
    } else {
        Write-Warning "Device $deviceName not found in Azure AD."
    }
}

Disconnect-AzureAD
