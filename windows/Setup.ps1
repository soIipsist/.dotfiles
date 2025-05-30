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

# windows settings
$global:PCName = $WindowsData.pc_name
$global:ProductKey = $WindowsData.product_key
$global:EnvironmentVariables = $WindowsData.environment_variables
$global:Shortcuts = $WindowsData.shortcuts
$global:EnabledFeatures = $WindowsData.enabled_features
$global:DisabledFeatures = $WindowsData.disabled_features
$global:FileExplorerStartFolder = $WindowsData.file_explorer_start_folder
$global:ShowFileExtensions = $WindowsData.show_file_extensions
$global:ClassicContextMenu = $WindowsData.classic_context_menu
$global:RemoveDesktopShortcuts = $WindowsData.remove_desktop_shortcuts
$global:RemoveWindowsWatermark = $WindowsData.remove_windows_watermark
$global:ActivateOffice = $WindowsData.activate_office
$global:FontsDirectory = Replace-Root -Value $WindowsData.fonts_directory -RootPath $ParentDirectory
$global:WallpaperPath = Replace-Root -Value $WindowsData.wallpaper_path -RootPath $ParentDirectory
$global:LockscreenPath = Replace-Root -Value $WindowsData.lockscreen_path -RootPath $ParentDirectory

# packages, dotfiles
$global:ExcludedScripts = $WindowsData.excluded_scripts
$global:Dotfiles = $WindowsData.dotfiles
$global:DotfilesDirectory = $WindowsData.dotfiles_directory
$global:ChocolateyPackages = $WindowsData.chocolatey_packages
$global:WingetPackages = $WindowsData.winget_packages
$global:WSLPackages = $WindowsData.wsl_packages
$global:ScoopPackages = $WindowsData.scoop_packages
$global:WindowsPackages = $WindowsData.windows_packages
$global:PipPackages = $WindowsData.pip_packages

$global:UninstallPackages = $WindowsData.uninstall_packages
$global:PackageProviders = $WindowsData.package_providers

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

# regional format
$global:FirstDayOfWeek = $WindowsData.first_day_of_week
$global:ShortDate = $WindowsData.short_date
$global:LongDate = $WindowsData.long_date
$global:ShortTime = $WindowsData.short_time
$global:TimeFormat = $WindowsData.time_format
$global:Timezone = $WindowsData.timezone 

# git
$global:GitUserName = $WindowsData.git_username
$global:GitUserEmail = $WindowsData.git_email

# reboot
$global:Reboot = $WindowsData.reboot
$global:RebootTime = $WindowsData.reboot_time

# system env
$global:UserProfilePath = [System.Environment]::GetFolderPath('UserProfile')
$global:StartMenuPath = "$UserProfilePath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
$global:ProgramFilesPath = [System.Environment]::GetFolderPath('ProgramFiles')
$global:ProgramFilesX86Path = [System.Environment]::GetFolderPath('ProgramFilesX86')

if ($args.Count -gt 0){
    $Dotfiles = $args
}

Write-Host $WindowsData
Set-PC-Name -PCName $PCName
Set-Product-Key -ProductKey $ProductKey
Set-Windows-Features -Enable $true -Features $EnabledFeatures
Set-Windows-Features -Enable $false -Features $DisabledFeatures
Set-Wallpaper -WallpaperPath $WallpaperPath
Set-Lockscreen -LockscreenPath $LockscreenPath
Set-FileExplorer-StartFolder -FileExplorerStartFolder $FileExplorerStartFolder
Set-Show-File-Extensions -ShowFileExtensions $ShowFileExtensions
Set-Classic-ContextMenu -ClassicContextMenu $ClassicContextMenu
Enable-Microsoft-Office -ActivateOffice $ActivateOffice
Install-Fonts $FontsDirectory

Set-Windows-Timezone $Timezone
Set-Power-Configuration -DiskTimeoutAC $DiskTimeoutAC -DiskTimeoutDC $DiskTimeoutDC -HibernateTimeoutAC $HibernateTimeoutAC -HibernateTimeoutDC $HibernateTimeoutDC -StandbyTimeoutAC $StandbyTimeoutAC -StandbyTimeoutDC $StandbyTimeoutDC -MonitorTimeoutAC $MonitorTimeoutAC -MonitorTimeoutDC $MonitorTimeoutDC -LockscreenTimeoutAC $LockscreenTimeoutAC -LockscreenTimeoutDC $LockscreenTimeoutDC
Set-Regional-Format -FirstDayOfWeek $FirstDayOfWeek -ShortDate $ShortDate -LongDate $LongDate -ShortTime $ShortTime -TimeFormat $TimeFormat

Install-PackageProviders -PackageProviders $PackageProviders
Install-Packages -Packages $ChocolateyPackages -PackageProvider "choco" -UninstallPackages $UninstallPackages
Install-Packages -Packages $ScoopPackages -PackageProvider "scoop" -UninstallPackages $UninstallPackages
Install-Packages -Packages $WingetPackages -PackageProvider "winget" -UninstallPackages $UninstallPackages
Install-Packages -Packages $PipPackages -PackageProvider "pip" -UninstallPackages $UninstallPackages
Install-Packages -Packages $WindowsPackages -PackageProvider "windows" -UninstallPackages $UninstallPackages
Install-Packages -Packages $WSLPackages -PackageProvider "wsl" -UninstallPackages $UninstallPackages

Install-Dotfiles -Dotfiles $Dotfiles -ExcludedScripts $ExcludedScripts -DotfilesDirectory $DotfilesDirectory
Set-Windows-Shortcuts -Shortcuts $Shortcuts
Set-Environment-Variables -EnvironmentVariables $EnvironmentVariables
Remove-Desktop-Shortcuts -RemoveDesktopShortcuts $RemoveDesktopShortcuts
Remove-Windows-Watermark -RemoveWindowsWatermark $RemoveWindowsWatermark

Write-Host "Setup was completed successfully." -ForegroundColor Green
Reboot -Reboot $Reboot -RebootTime $RebootTime

