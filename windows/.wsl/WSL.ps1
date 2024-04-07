$ParentDirectory = Split-Path -Path $PSScriptRoot -Parent
$DotfilesDirectory = Join-Path -Path $ParentDirectory -ChildPath "Dotfiles"
$PackagesDirectory = Join-Path -Path $ParentDirectory -ChildPath "Packages"
$HelpersDirectory = Join-Path -Path $ParentDirectory -ChildPath "Helpers"

. $DotfilesDirectory
. $PackagesDirectory
. $HelpersDirectory

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
    wsl --install -d ubuntu;
    refreshenv;

}

function WSLConfigOnRestart {
    if ($UninstallPackages) {
        return
    }
    # Update ubuntu
    wsl sudo -s
    wsl apt --yes update;
    wsl apt --yes upgrade;

    $WSLPackages = @("curl", "neofetch", "git", "vim", "zsh", "make", "g++", "gcc")
    Install-Packages -Packages $WSLPackages -PackageProvider "wsl"
    refreshenv;

    wsl git config --global init.defaultBranch "main";
    if ($GitUserName) {
        Write-Host "Successfully set git username to $GitUserName"
        wsl git config --global user.name $GitUserName;
    }
    if ($GitUserEmail) {
        Write-Host "Successfully set git email to $GitUserEmail"
        wsl git config --global user.email $GitUserEmail;
    }
    wsl git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe";
    wsl git config --list;

    refreshenv;

    # add custom actions
    $CustomActionsPath = Join-Path -Path $PSScriptRoot -ChildPath "custom-actions.sh"

    Write-Host "Installing custom alias and functions for Ubuntu:" -ForegroundColor Green;
    wsl mkdir -p "~/.oh-my-zsh/custom/functions";
    
    $Dotfiles = @($CustomActionsPath)
    Move-Dotfiles -Dotfiles $Dotfiles

    if ( Test-Path -Path $CustomActionsPath) {
        wsl cp -r "/mnt/c/Users/$env:USERNAME/custom-actions.sh" ~/.oh-my-zsh/custom/functions;
    }
    
}


WSLConfig


# schedule wsl on restart task
$TaskName = "WSLConfigOnRestart"
$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "WSL.ps1"

Unregister-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
$PSPath = (Get-Command powershell.exe).Definition
$FunctionName = "WSLConfigOnRestart"
$Action = New-ScheduledTaskAction -Execute $PSPath -Argument "-NonInteractive -NoProfile -NoLogo -NoProfile -NoExit -Command `"& { Import-Module PSWorkflow; . '$ScriptPath'; $FunctionName }`""
$Option = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
$Trigger = New-JobTrigger -AtLogOn -RandomDelay (New-TimeSpan -Seconds 10)
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Option -RunLevel Highest
Reboot -Reboot $true

Write-Host "WSL was successfully configured." -ForegroundColor Green;