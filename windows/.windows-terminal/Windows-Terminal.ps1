
$WindowsTerminalPackage = [PSCustomObject]@{
    Name   = 'Microsoft.WindowsTerminal'
    Params = @()
}

$Packages = @($WindowsTerminalPackage)
$global:DestinationDirectory = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

Install-Packages -Packages $Packages -PackageProvider "winget" -UninstallPackages $UninstallPackages
Write-Host "Windows Terminal was successfully configured." -ForegroundColor Green;