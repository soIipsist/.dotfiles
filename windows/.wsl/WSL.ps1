$ParentDirectory = Split-Path -Path $PSScriptRoot -Parent
$DotfilesDirectory = Join-Path -Path $ParentDirectory -ChildPath "Dotfiles"
$PackagesDirectory = Join-Path -Path $ParentDirectory -ChildPath "Packages"
$HelpersDirectory = Join-Path -Path $ParentDirectory -ChildPath "Helpers"
$VarsDirectory = Join-Path -Path $ParentDirectory -ChildPath "Variables"

. $DotfilesDirectory
. $PackagesDirectory
. $HelpersDirectory
. $VarsDirectory

function WSLConfig {
    if ($UninstallPackages) {
        return
    }
    $WSL2Package = [PSCustomObject]@{
        Name   = 'wsl2'
        Params = @("/Version:2", "/Retry:true")
    }

    $WSLUbuntuPackage = [PSCustomObject]@{
        Name   = "wsl-ubuntu-2004"
        Params = @("/InstallRoot:true", "--execution-timeout", "3600")
    } 

    $Packages = @($WSL2Package, $WSLUbuntuPackage)
    Install-Packages -Packages $Packages -UninstallPackages $UninstallPackages
    wsl --install --no_launch -d ubuntu;
    refreshenv;

}



WSLConfig

$TaskName = "WSLConfigOnRestart"
$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "WSLRestart.ps1"
Set-ScheduledTask -TaskName $TaskName -ScriptPath $ScriptPath -DelayInSeconds 10

Write-Host "WSL was successfully configured." -ForegroundColor Green;