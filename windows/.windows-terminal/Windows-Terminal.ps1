
. "../windows/Dotfiles.ps1"

$Dotfiles = Get-Dotfiles $PSScriptRoot

$WindowsTerminalPackage = [PSCustomObject]@{
    Name   = 'microsoft-windows-terminal'
    Params = @()
}

$Packages = @($WindowsTerminalPackage)
$DestinationDirectory = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"


Install-Packages -Packages $Packages -UninstallPackages $UninstallPackages
Write-Host "Windows Terminal was successfully configured." -ForegroundColor Green;