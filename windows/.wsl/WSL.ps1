. "../windows/Dotfiles.ps1"

function WSLConfig {
    if ($UninstallPackages) {
        return
    }
    wsl --install -d ubuntu;
    refreshenv;
    
    # Update ubuntu
    wsl sudo apt --yes update;
    wsl sudo apt --yes upgrade;

    $WSLPackages = @("curl", "neofetch", "git", "vim", "zsh", "make", "g++", "gcc")
    foreach ($Package in $WSLPackages) {
        Install-Packages -Packages $WSLPackages -PackageProvider "wsl"
    }
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
refreshenv;
WSLConfig
Write-Host "WSL was successfully configured." -ForegroundColor Green;