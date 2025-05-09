$ParentDirectory = Split-Path -Path $PSScriptRoot -Parent
$DotfilesDirectory = Join-Path -Path $ParentDirectory -ChildPath "Dotfiles"
$PackagesDirectory = Join-Path -Path $ParentDirectory -ChildPath "Packages"
$HelpersDirectory = Join-Path -Path $ParentDirectory -ChildPath "Helpers"
$VarsDirectory = Join-Path -Path $ParentDirectory -ChildPath "Variables"
$WindowsSetupDirectory = Join-Path -Path $ParentDirectory -ChildPath "Windows-Setup"

. $DotfilesDirectory
. $PackagesDirectory
. $HelpersDirectory
. $VarsDirectory
. $WindowsSetupDirectory

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1

$WSL2Package = [PSCustomObject]@{
    Name   = 'wsl2'
    Params = @("/Version:2", "/Retry:true")
}

# $WSLUbuntuPackage = [PSCustomObject]@{
#     Name   = "wsl-ubuntu-2004"
#     Params = @("/InstallRoot:true", "--execution-timeout", "3600")
# } 

# install wsl packages
$Packages = @($WSL2Package)
Install-Packages -Packages $Packages -UninstallPackages $UninstallPackages

if ($UninstallPackages){
   wsl --unregister Ubuntu
   wsl --uninstall
   $global:DestinationDirectory="$null"
   return
}else{
    wsl --install -d ubuntu;
}

refreshenv;
Start-Sleep -Seconds 5

# update ubuntu
wsl sudo apt --yes update;
wsl sudo apt --yes upgrade;

$WSLPackages = @("curl", "neofetch", "git", "vim", "zsh", "make", "g++", "gcc", "build-essential", "procps", "file")
Install-Packages -Packages $WSLPackages -PackageProvider "wsl"

# config git
wsl git config --global init.defaultBranch "main";

if ($GitUserName) {
    Write-Host "Successfully set git username to $GitUserName" -ForegroundColor Green
    wsl git config --global user.name $GitUserName; 
}
if ($GitUserEmail) {
    Write-Host "Successfully set git email to $GitUserEmail" -ForegroundColor Green
    wsl git config --global user.email $GitUserEmail;
}

wsl git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe";
wsl git config --list;

$user = wsl whoami
wsl git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# install homebrew
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" -OutFile "$env:TEMP\install.sh"
$wslPath = "$env:TEMP\install.sh"
wsl /bin/bash -c "bash /mnt/$user/Users/p/AppData/Local/Temp/install.sh"


$global:DestinationDirectory="\\wsl$\Ubuntu\home\$user"
Write-Host "WSL was successfully configured." -ForegroundColor Green;