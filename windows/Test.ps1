# Include files
$ScriptRootDirectory = $PSScriptRoot
$ParentDirectory = Split-Path -Path $PSScriptRoot -Parent
$HelpersPath = Join-Path -Path $ScriptRootDirectory -ChildPath "Helpers.ps1"
$RegistryPath = Join-Path -Path $ScriptRootDirectory -ChildPath "Registry.ps1"
$DotfilesPath = Join-Path -Path $ScriptRootDirectory -ChildPath "Dotfiles.ps1"
$VariablesPath = Join-Path -Path $ScriptRootDirectory -ChildPath "Variables.ps1"
$SetupPath = Join-Path -Path $ScriptRootDirectory -ChildPath "Windows-Setup.ps1"
$ProvidersPath = Join-Path -Path $ScriptRootDirectory -ChildPath "Package-Providers.ps1"
$PackagesPath = Join-Path -Path $ScriptRootDirectory -ChildPath "Packages.ps1"

. $HelpersPath
. $RegistryPath
. $DotfilesPath
. $VariablesPath
. $SetupPath
. $ProvidersPath
. $PackagesPath

$WindowsDataPath = Join-Path -Path $ScriptRootDirectory -ChildPath "windows.json"
# $WindowsDataPath = "..\windows\windows_example.json"

$WindowsData = Get-Content -Path $WindowsDataPath -Raw | ConvertFrom-Json
$WindowsData = Get-Default-Values-From-Json -WindowsData $WindowsData -DotfilesDirectory $ScriptRootDirectory

$global:ExcludedScripts = $WindowsData.excluded_scripts
$global:Dotfiles = $WindowsData.dotfiles
$global:DotfilesDirectory = $WindowsData.dotfiles_directory

# git
$global:GitUserName = $WindowsData.git_username
$global:GitUserEmail = $WindowsData.git_email

# system env
$global:UserProfilePath = [System.Environment]::GetFolderPath('UserProfile')
$global:StartMenuPath = "$UserProfilePath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
$global:ProgramFilesPath = [System.Environment]::GetFolderPath('ProgramFiles')
$global:ProgramFilesX86Path = [System.Environment]::GetFolderPath('ProgramFilesX86')

$global:RemoveWindowsWatermark = $WindowsData.remove_windows_watermark

if ($args.Count -gt 0){
    $Dotfiles = $args
}

# power configuration
$global:DiskTimeoutAC = $WindowsData.disk_timeout_ac
$global:DiskTimeoutDC = $WindowsData.disk_timeout_dc
$global:HibernateTimeoutAC = $WindowsData.hibernate_timeout_ac
$global:HibernateTimeoutDC = $WindowsData.hibernate_timeout_dc
$global:MonitorTimeoutAC = $WindowsData.monitor_timeout_ac
$global:MonitorTimeoutDC = $WindowsData.monitor_timeout_dc
$global:StandbyTimeoutAC = $WindowsData.standby_timeout_ac
$global:StandbyTimeoutDC = $WindowsData.standby_timeout_dc
$global:LockscreenTimeoutAC = $WindowsData.lockscreen_timeout_ac
$global:LockscreenTimeoutDC = $WindowsData.lockscreen_timeout_dc


Remove-Windows-Watermark -RemoveWindowsWatermark $RemoveWindowsWatermark
Set-Power-Configuration -DiskTimeoutAC $DiskTimeoutAC -DiskTimeoutDC $DiskTimeoutDC -HibernateTimeoutAC $HibernateTimeoutAC -HibernateTimeoutDC $HibernateTimeoutDC -StandbyTimeoutAC $StandbyTimeoutAC -StandbyTimeoutDC $StandbyTimeoutDC -MonitorTimeoutAC $MonitorTimeoutAC -MonitorTimeoutDC $MonitorTimeoutDC -LockscreenTimeoutAC $LockscreenTimeoutAC -LockscreenTimeoutDC $LockscreenTimeoutDC

# Write-Host "Dotfile dirs" $DotfileDirectories -ForegroundColor Green 

# foreach ($Directory in $DotfileDirectories){
#     $DotfileScripts = Get-Dotfile-Scripts -DotfileFolderPath $Directory
#     $Dotfiles = Get-Dotfiles -DotfileFolderPath $Directory

#     Write-Host "Dotfile scripts" $DotfileScripts -ForegroundColor Green 
#     Write-Host "Dotfiles" $Dotfiles -ForegroundColor Green
# }

# Install-Dotfiles -Dotfiles $Dotfiles -ExcludedScripts $ExcludedScripts -DotfilesDirectory $DotfilesDirectory
 
