Write-Host  -ForegroundColor Green "Starting ZeroTouch Cloud Imaging"
Start-Sleep -Seconds 5

# Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Green "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

# Make sure I have the latest OSD Content
Write-Host  -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force

# Start-OSDCloud with Params
Write-Host  -ForegroundColor Green "Installing Windows 10 Pro 21H2 Operating System"
$Params = @{
    OSBuild = "21H2"
    OSEdition = "Pro"
    OSLanguage = "en-us"
    ZTI = $True
}
Start-OSDCloud @Params

# OOBEDeploy Bloatware Removal, Update Windows & Drivers
Write-Host  -ForegroundColor Green "Removing Bloatware and Updating Windows & Drivers"
$Params = @{
    RemoveAppx = "Skype","Solitaire","Xbox","ZuneMusic","ZuneVideo"
    UpdateDrivers = $true
    UpdateWindows = $true
}
Start-OOBEDeploy @Params

# Set OOBEDeploy CMD.ps1
$SetCommand = @'
@echo off
:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts
:: Open and Minimize a PowerShell instance just in case
start PowerShell -NoL -W Mi
:: Install the latest OSD Module
start "Install-Module OSD" /wait PowerShell -NoL -C Install-Module OSD -Force -Verbose
:: Start-OOBEDeploy
:: The next line assumes that you have a configuration saved in C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json
start "Start-OOBEDeploy" PowerShell -NoL -C Start-OOBEDeploy
exit
'@
$SetCommand | Out-File -FilePath "C:\Windows\OOBEDeploy.cmd" -Encoding ascii -Force

# Restart from WinPE
Write-Host  -ForegroundColor Green "Restarting in 10 seconds!"
Start-Sleep -Seconds 10
wpeutil reboot
