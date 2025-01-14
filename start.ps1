##### Welcome to the CDFC Script. This script will automate the following tasks:
##### This script will rename the computer, set a static IP, install and configure AD DS and DNS, promote to Domain Controller, install and disable FTP feature, create users, groups, folders, public folder and acl, organizational units, and disable Auto-Login.

# This part will ensure script continues after reboot
$scriptPath = $MyInvocation.MyCommand.Path
$restartCommand = "powershell.exe -ExecutionPolicy Bypass -File `"$scriptPath`""
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "RestartScript" -Value $restartCommand

# Parameters for Auto-Login
$defaultUserName = "Administrator"
$defaultPassword = "P@ssw0rd"

# Registry Path
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Enable Auto-Login by setting registry keys
Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value $defaultUserName
Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $defaultPassword

# Create a checkpoint registry key to bypass any steps that have already been applied.
$checkpointKey = "HKLM:\SOFTWARE\CDFCScript"
$checkpointValue = "LastCompletedStep"
if (!(Test-Path $checkpointKey)) {
    New-Item -Path $checkpointKey -Force | Out-Null
}
$lastStep = Get-ItemProperty -Path $checkpointKey -Name $checkpointValue -ErrorAction SilentlyContinue

# Rename server
if ($null -eq $lastStep -or $lastStep.LastCompletedStep -lt 1) {
    Rename-Computer -NewName "CDFCsvr" -Force
    Set-ItemProperty -Path $checkpointKey -Name $checkpointValue -Value 1

    Write-Host "Computer rename is done. System is going to reboot now..."
    Start-Sleep -Seconds 5  # Giving some time for the reboot process
    # Reboot to apply changes
    Restart-Computer -Force
}

# Set static IP
if ($null -eq $lastStep -or $lastStep.LastCompletedStep -lt 2) {
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
    New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress 10.10.10.34 -PrefixLength 27 -DefaultGateway 10.10.10.33
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses 10.10.10.34
    Set-ItemProperty -Path $checkpointKey -Name $checkpointValue -Value 2
}

# Install and configure AD DS and DNS
if ($null -eq $lastStep -or $lastStep.LastCompletedStep -lt 3) {
    Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools
    Set-ItemProperty -Path $checkpointKey -Name $checkpointValue -Value 3
}

# Promote to Domain Controller
if ($null -eq $lastStep -or $lastStep.LastCompletedStep -lt 4) {
    $securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
    Install-ADDSForest -DomainName "CDFC.local" -InstallDNS -SafeModeAdministratorPassword $securePassword -Force
    Set-ItemProperty -Path $checkpointKey -Name $checkpointValue -Value 4
    # Reboot to apply changes
    Restart-Computer -Force
}

# Install and disable FTP feature
Install-WindowsFeature -Name Web-Ftp-Server
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\FTPSVC" -Name Start -Value 4

# Create users, This script is in the same directory
. "$PSScriptRoot\createuser.ps1"

# Create groups, This script is in the same directory
. "$PSScriptRoot\creategroup.ps1"

# Create folders, public folder and acl, This script is in the same directory
. "$PSScriptRoot\createdir.ps1"

# Create organizational units, This script is in the same directory
. "$PSScriptRoot\createorg.ps1"

# Disable Auto-Login
Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "0"
Remove-ItemProperty -Path $regPath -Name "DefaultPassword" -ErrorAction SilentlyContinue

# Remove restart trigger, so the script will not run again after reboot
Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "RestartScript"

Write-Host "All the steps are completed successfully. Thank you!!!"
Start-Sleep -Seconds 5