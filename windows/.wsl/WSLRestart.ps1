$ParentDirectory = Split-Path -Path $PSScriptRoot -Parent
$DotfilesDirectory = Join-Path -Path $ParentDirectory -ChildPath "Dotfiles"
$PackagesDirectory = Join-Path -Path $ParentDirectory -ChildPath "Packages"
$HelpersDirectory = Join-Path -Path $ParentDirectory -ChildPath "Helpers"
$VarsDirectory = Join-Path -Path $ParentDirectory -ChildPath "Variables"

. $DotfilesDirectory
. $PackagesDirectory
. $HelpersDirectory
. $VarsDirectory

function WSLConfigOnRestart {
    if ($UninstallPackages) {
        return
    }
    # Update ubuntu
    wsl sudo apt --yes update;
    wsl sudo apt --yes upgrade;

    $WSLPackages = @("curl", "neofetch", "git", "vim", "zsh", "make", "g++", "gcc")
    Install-Packages -Packages $WSLPackages -PackageProvider "wsl"

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


    # add custom actions
    $CustomActionsPath = Join-Path -Path $PSScriptRoot -ChildPath "custom-actions.sh"

    Write-Host "Installing custom alias and functions for Ubuntu:" -ForegroundColor Green;
    wsl mkdir -p "~/.oh-my-zsh/custom/functions";
    
    $Dotfiles = @($CustomActionsPath)
    Move-Dotfiles -Dotfiles $Dotfiles

    if ( Test-Path -Path $CustomActionsPath) {
        wsl cp -r "/mnt/c/Users/$env:USERNAME/custom-actions.sh" ~/.oh-my-zsh/custom/functions;
    }

    # $TaskName = "WSLConfigOnRestart"
    # Unregister-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    
}

WSLConfigOnRestart
$DestinationDirectory=""