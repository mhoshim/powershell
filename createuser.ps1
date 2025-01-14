# Create AD users with provided information in the assignment
$users = @(
    @{
        UserID = "Staff1"
        Password = "P@ssw0rd"
        Description = "First Salesperson"
        ExpiryDate = "12/31/2026"
        City = "Regina"
        Province = "Saskatchewan"
    },
    @{
        UserID = "Staff2"
        Password = "P@ssw0rd"
        Description = "Second Salesperson"
        ExpiryDate = $null
        City = "Winnipeg"
        Province = "Manitoba"
    },
    @{
        UserID = "Staff3"
        Password = "P@ssw0rd"
        Description = "Third Salesperson"
        ExpiryDate = "12/31/2025"
        City = "Dauphin"
        Province = "Manitoba"
    },
    @{
        UserID = "Staff4"
        Password = "P@ssw0rd"
        Description = "Fourth Salesperson"
        ExpiryDate = "12/31/2028"
        City = "Thompson"
        Province = "Manitoba"
    }
)

foreach ($user in $users) {
    $securePassword = ConvertTo-SecureString $user.Password -AsPlainText -Force
    $expirationDate = if ($user.ExpiryDate) { [DateTime]::ParseExact($user.ExpiryDate, "MM/dd/yyyy", $null) } else { $null }
    
    New-ADUser -Name $user.UserID `
               -SamAccountName $user.UserID `
               -UserPrincipalName "$($user.UserID)@CDFC.local" `
               -AccountPassword $securePassword `
               -Enabled $true `
               -Description $user.Description `
               -City $user.City `
               -State $user.Province `
               -HomeDirectory "C:\Users\$($user.UserID)" `
               -HomeDrive "H:" `
               -AccountExpirationDate $expirationDate `
               -PasswordNeverExpires $true `
               -ChangePasswordAtLogon $false
    
    # Create home directory
    New-Item -Path "C:\Users\$($user.UserID)" -ItemType Directory -Force
}
