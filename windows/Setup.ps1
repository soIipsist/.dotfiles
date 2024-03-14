# Include files
. "..\windows\Helpers.ps1"
. "..\windows\Registry.ps1"
. "..\windows\Dotfiles.ps1"
. "..\windows\Variables.ps1"
. "..\windows\Windows-Setup.ps1"
. "..\windows\Package-Providers.ps1"
. "..\windows\Packages.ps1"

Set-PC-Name -PCName $PCName
Set-Product-Key -ProductKey $ProductKey
Set-Windows-Features -Enable $true -Features $EnabledFeatures
Set-Windows-Features -Enable $false -Features $DisabledFeatures
Set-FileExplorer-StartFolder -FileExplorerStartFolder $FileExplorerStartFolder
Set-Show-File-Extensions -ShowFileExtensions $ShowFileExtensions
Set-Classic-ContextMenu -ClassicContextMenu $ClassicContextMenu
Enable-Microsoft-Office -ActivateOffice $ActivateOffice
Set-Wallpaper -WallpaperPath $WallpaperPath
Set-Lockscreen -LockscreenPath $LockscreenPath
Install-Fonts $FontsDirectory
Set-Power-Configuration -DiskTimeoutAC $DiskTimeoutAC -DiskTimeoutDC $DiskTimeoutDC -HibernateTimeoutAC $HibernateTimeoutAC -HibernateTimeoutDC $HibernateTimeoutDC -StandbyTimeoutAC $StandbyTimeoutAC -StandbyTimeoutDC $StandbyTimeoutDC -MonitorTimeoutAC $MonitorTimeoutAC -MonitorTimeoutDC $MonitorTimeoutDC -LockscreenTimeoutAC $LockscreenTimeoutAC -LockscreenTimeoutDC $LockscreenTimeoutDC
Set-Regional-Format -FirstDayOfWeek $FirstDayOfWeek -ShortDate $ShortDate -LongDate $LongDate -ShortTime $ShortTime -TimeFormat $TimeFormat

if ($Timezone) {
    Set-TimeZone $Timezone
}

Set-Environment-Variables -EnvironmentVariables $EnvironmentVariables

Install-PackageProviders -PackageProviders $PackageProviders
Install-Packages -Packages $PackageData -UninstallPackages $UninstallPackages
Install-Packages -Packages $ChocolateyPackages -PackageProvider "choco" -UninstallPackages $UninstallPackages
Install-Packages -Packages $ScoopPackages -PackageProvider "scoop" -UninstallPackages $UninstallPackages
Install-Packages -Packages $WingetPackages -PackageProvider "winget" -UninstallPackages $UninstallPackages
Install-Packages -Packages $PipPackages -PackageProvider "pip" -UninstallPackages $UninstallPackages
Install-Packages -Packages $WindowsPackages -PackageProvider "windows" -UninstallPackages $UninstallPackages
Install-Packages -Packages $WSLPackages -PackageProvider "wsl" -UninstallPackages $UninstallPackages
Install-Dotfiles $Dotfiles

Set-Windows-Shortcuts -Shortcuts $Shortcuts
Remove-Desktop-Shortcuts -RemoveDesktopShortcuts $RemoveDesktopShortcuts
Reboot -Reboot $Reboot -RebootTime $RebootTime
